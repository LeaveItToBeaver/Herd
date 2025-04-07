const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { onDocumentCreated, onDocumentDeleted, onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { logger } = require("firebase-functions");

admin.initializeApp();
const firestore = admin.firestore();

// Hot algorithm implementation for post ranking - this stays mostly the same
const hotAlgorithm = {
  calculateHotScore: (netVotes, createdAt, decayFactor = 1.0) => {
    // Logarithmic scoring that accounts for recency and engagement
    const sign = Math.sign(netVotes);
    const magnitude = Math.log10(Math.max(1, Math.abs(netVotes)));

    // Time component with adjustable decay
    const timeSinceCreation = (Date.now() - createdAt.getTime()) / 1000;
    const timeDecay = Math.pow(timeSinceCreation, -0.5) * decayFactor;

    return sign * magnitude * timeDecay;
  },

  sortPosts: (posts, decayFactor = 1.0) => {
    return posts.sort((a, b) => {
      const aScore = hotAlgorithm.calculateHotScore(
        a.likeCount - a.dislikeCount,
        a.createdAt,
        decayFactor
      );
      const bScore = hotAlgorithm.calculateHotScore(
        b.likeCount - b.dislikeCount,
        b.createdAt,
        decayFactor
      );
      return bScore - aScore;
    });
  }
};

/**
 * Fan-out post to followers' feeds when a new post is created
 * This is the core function for the write-time fan-out pattern
 */
exports.distributePost = onDocumentCreated(
  "posts/{postId}",
  async (event) => {
    const postId = event.params.postId;
    const postData = event.data.data();

    // Validate post data
    if (!postData || !postData.authorId) {
      logger.error(`Invalid post data for ID: ${postId}`);
      return null;
    }

    // Compute initial hot score
    const initialHotScore = hotAlgorithm.calculateHotScore(
      0, // New posts start with 0 net votes
      postData.createdAt ? postData.createdAt.toDate() : new Date()
    );

    // Enhanced post data with feed metadata
    const enhancedPostData = {
      ...postData,
      hotScore: initialHotScore,
      feedType: postData.herdId ? 'herd' : (postData.isAlt ? 'alt' : 'public')
    };

    try {
      // Handle distribution based on post type
      if (postData.isAlt) {
        // For alt posts - add to global alt feed collection
        await firestore.collection('altPosts').doc(postId).set(enhancedPostData);

        // Also add to author's feed so they can see their own post
        await firestore
          .collection("userFeeds")
          .doc(postData.authorId)
          .collection("feed")
          .doc(postId)
          .set(enhancedPostData);

        logger.info(`Added alt post ${postId} to global feed and author's feed`);
      }
      else if (postData.feedType === 'public') {
        // For public posts - distribute to followers
        const followersSnapshot = await firestore
          .collection("followers")
          .doc(postData.authorId)
          .collection("userFollowers")
          .get();

        const targetUserIds = followersSnapshot.docs.map(doc => doc.id);

        // Add author to recipient list (they see their own posts)
        if (!targetUserIds.includes(postData.authorId)) {
          targetUserIds.push(postData.authorId);
        }

        // Fan out to followers' feeds
        await fanOutToUserFeeds(postId, enhancedPostData, targetUserIds);
        logger.info(`Distributed public post ${postId} to ${targetUserIds.length} followers`);
      }

      // If post belongs to a herd, handle herd-specific distribution
      if (postData.herdId) {
        // Add to herd collection
        await firestore
          .collection("herdPosts")
          .doc(postData.herdId)
          .collection("posts")
          .doc(postId)
          .set(enhancedPostData);

        // Get herd details to check if private
        const herdDoc = await firestore.collection("herds").doc(postData.herdId).get();
        const herdData = herdDoc.data();
        const isPrivateHerd = herdData?.isPrivate || false;

        // Fan out to herd members
        const herdMembersSnapshot = await firestore
          .collection("herdMembers")
          .doc(postData.herdId)
          .collection("members")
          .get();

        const herdMemberIds = herdMembersSnapshot.docs.map(doc => doc.id);
        await fanOutToUserFeeds(postId, enhancedPostData, herdMemberIds);

        // For public herds, add to the global alt feed for discovery
        if (!isPrivateHerd) {
          await firestore.collection('altPosts').doc(postId).set(enhancedPostData);
          logger.info(`Added herd post ${postId} to global alt feed (public herd)`);
        }

        logger.info(`Distributed herd post ${postId} to ${herdMemberIds.length} members`);
      }

      return null;
    } catch (error) {
      logger.error(`Error distributing post ${postId}:`, error);
      throw error;
    }
  }
);

// Helper function for fan-out operations
async function fanOutToUserFeeds(postId, postData, userIds) {
  if (userIds.length === 0) return;

  // Batch processing
  const MAX_BATCH_SIZE = 500; // Firestore limit
  let batch = firestore.batch();
  let operationCount = 0;

  for (const userId of userIds) {
    const userFeedRef = firestore
      .collection("userFeeds")
      .doc(userId)
      .collection("feed")
      .doc(postId);

    batch.set(userFeedRef, postData);
    operationCount++;

    // If batch is full, commit and reset
    if (operationCount >= MAX_BATCH_SIZE) {
      await batch.commit();
      batch = firestore.batch();
      operationCount = 0;
    }
  }

  // Commit any remaining operations
  if (operationCount > 0) {
    await batch.commit();
  }
}
/**
 * Remove post from all feeds when the post is deleted
 */
exports.removeDeletedPost = onDocumentDeleted(
  "posts/{postId}",
  async (event) => {
    const postId = event.params.postId;
    const postData = event.data.data();

    if (!postData) {
      logger.error(`No post data found for deleted ID: ${postId}`);
      return null;
    }

    try {
      // Find all user feeds containing this post
      const feedQuery = firestore
        .collectionGroup("feed")
        .where("__name__", "==", postId)
        .select(); // Use select() to minimize data read

      const feedEntries = await feedQuery.get();

      if (feedEntries.empty) {
        logger.info(`No feed entries found for deleted post ${postId}`);
        return null;
      }

      logger.info(`Removing deleted post ${postId} from ${feedEntries.size} feeds`);

      // Batch delete from all feeds
      const MAX_BATCH_SIZE = 500;
      let batch = firestore.batch();
      let operationCount = 0;

      for (const doc of feedEntries.docs) {
        batch.delete(doc.ref);
        operationCount++;

        if (operationCount >= MAX_BATCH_SIZE) {
          await batch.commit();
          batch = firestore.batch();
          operationCount = 0;
        }
      }

      if (operationCount > 0) {
        await batch.commit();
      }

      logger.info(`Successfully removed deleted post ${postId} from all feeds`);
      return null;
    } catch (error) {
      logger.error(`Error removing deleted post ${postId}:`, error);
      throw error;
    }
  }
);

/**
 * Update post hot scores across all feeds when a post is liked/disliked
 */
exports.updatePostInFeeds = onDocumentUpdated(
  "posts/{postId}",
  async (event) => {
    const postId = event.params.postId;
    const beforeData = event.data.before.data();
    const afterData = event.data.after.data();

    // Only process if engagement metrics have changed
    if (
      beforeData.likeCount === afterData.likeCount &&
      beforeData.dislikeCount === afterData.dislikeCount
    ) {
      return null;
    }

    try {
      // Calculate new hot score
      const netVotes = afterData.likeCount - afterData.dislikeCount;
      const createdAt = afterData.createdAt.toDate();
      const updatedHotScore = hotAlgorithm.calculateHotScore(netVotes, createdAt);

      // Find all user feeds containing this post
      const feedQuery = firestore
        .collectionGroup("feed")
        .where("__name__", "==", postId)
        .select(); // Use select() to minimize data read

      const feedEntries = await feedQuery.get();

      if (feedEntries.empty) {
        logger.info(`No feed entries found for post ${postId}`);
        return null;
      }

      logger.info(`Updating hot score for post ${postId} in ${feedEntries.size} feeds`);

      // Batch update all feeds
      const MAX_BATCH_SIZE = 500;
      let batch = firestore.batch();
      let operationCount = 0;

      for (const doc of feedEntries.docs) {
        batch.update(doc.ref, { hotScore: updatedHotScore });
        operationCount++;

        if (operationCount >= MAX_BATCH_SIZE) {
          await batch.commit();
          batch = firestore.batch();
          operationCount = 0;
        }
      }

      if (operationCount > 0) {
        await batch.commit();
      }

      logger.info(`Successfully updated post ${postId} hot score in all feeds`);
      return null;
    } catch (error) {
      logger.error(`Error updating post ${postId} in feeds:`, error);
      throw error;
    }
  }
);

/**
 * Handle post interactions (likes/dislikes) with the unified feed approach
 */
exports.handlePostInteraction = onCall(async (request) => {
  const {
    postId,
    interactionType,
  } = request.data;

  // Validate authentication
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'User must be logged in');
  }

  const userId = request.auth.uid;

  // Reference to the source-of-truth post
  const postRef = firestore.collection('posts').doc(postId);

  return firestore.runTransaction(async (transaction) => {
    const postDoc = await transaction.get(postRef);

    if (!postDoc.exists) {
      throw new HttpsError('not-found', 'Post not found');
    }

    const postData = postDoc.data();
    const interactions = {
      like: {
        incrementField: 'likeCount',
        decrementField: 'dislikeCount',
        collection: 'likes'
      },
      dislike: {
        incrementField: 'dislikeCount',
        decrementField: 'likeCount',
        collection: 'dislikes'
      }
    };

    const config = interactions[interactionType];
    if (!config) {
      throw new HttpsError('invalid-argument', 'Invalid interaction type');
    }

    const interactionRef = firestore
      .collection(config.collection)
      .doc(postId)
      .collection('userInteractions')
      .doc(userId);

    // Check current interaction state
    const currentInteraction = await transaction.get(interactionRef);
    const isCurrentlyInteracted = currentInteraction.exists;

    // Update interaction counts
    transaction.update(postRef, {
      [config.incrementField]:
        admin.firestore.FieldValue.increment(isCurrentlyInteracted ? -1 : 1),
      [config.decrementField]:
        admin.firestore.FieldValue.increment(0) // Placeholder, updated later if needed
    });

    // Toggle interaction document
    if (isCurrentlyInteracted) {
      transaction.delete(interactionRef);
    } else {
      transaction.set(interactionRef, {
        timestamp: admin.firestore.FieldValue.serverTimestamp()
      });

      // Check if opposite interaction exists
      const oppositeCollection = interactionType === 'like' ? 'dislikes' : 'likes';
      const oppositeRef = firestore
        .collection(oppositeCollection)
        .doc(postId)
        .collection('userInteractions')
        .doc(userId);

      const oppositeInteraction = await transaction.get(oppositeRef);

      if (oppositeInteraction.exists) {
        transaction.delete(oppositeRef);
        transaction.update(postRef, {
          [config.decrementField]: admin.firestore.FieldValue.increment(-1)
        });
      }
    }

    // Calculate updated hot score (will be propagated to feeds via the updatePostInFeeds trigger)
    const updatedLikeCount = postData.likeCount + (isCurrentlyInteracted ? -1 : 1);
    const updatedDislikeCount = postData.dislikeCount; // Simplified for this example
    const netVotes = updatedLikeCount - updatedDislikeCount;
    const updatedHotScore = hotAlgorithm.calculateHotScore(
      netVotes,
      postData.createdAt.toDate()
    );

    transaction.update(postRef, { hotScore: updatedHotScore });

    // If not the author, update user points
    if (postData.authorId !== userId) {
      const pointChange = isCurrentlyInteracted ? -1 : 1;
      const authorRef = firestore.collection('users').doc(postData.authorId);
      transaction.update(authorRef, {
        userPoints: admin.firestore.FieldValue.increment(pointChange)
      });
    }

    return {
      success: true,
      hotScore: updatedHotScore,
      isLiked: interactionType === 'like' && !isCurrentlyInteracted,
      isDisliked: interactionType === 'dislike' && !isCurrentlyInteracted
    };
  });
});

/**
 * Get feed for a user with filtering options
 */
exports.getFeed = onCall(async (request) => {
  const {
    feedType = 'public', // 'public', 'alt', or 'all'
    herdId = null,       // Optional herd filter
    limit = 20,
    lastHotScore = null,
    lastPostId = null
  } = request.data;

  // Validate authentication
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'User must be logged in');
  }

  const userId = request.auth.uid;

  try {
    // Different query strategy based on feed type
    if (feedType === 'public') {
      // Public feed - query user's personalized feed collection
      return await getPublicFeed(userId, limit, lastHotScore, lastPostId);
    }
    else if (feedType === 'alt') {
      // Alt feed - query global alt feed collection
      return await getAltFeed(limit, lastHotScore, lastPostId);
    }
    else if (herdId) {
      // Herd-specific feed
      return await getHerdFeed(herdId, limit, lastHotScore, lastPostId);
    }

    // Default - return public feed
    return await getPublicFeed(userId, limit, lastHotScore, lastPostId);
  } catch (error) {
    logger.error(`Error getting feed for user ${userId}:`, error);
    throw new HttpsError('internal', `Failed to get feed: ${error.message}`);
  }
});

// Get public feed (personalized for each user)
async function getPublicFeed(userId, limit, lastHotScore, lastPostId) {
  let feedQuery = firestore
    .collection('userFeeds')
    .doc(userId)
    .collection('feed')
    .where('feedType', '==', 'public')
    .orderBy('hotScore', 'desc');

  // Apply pagination
  if (lastHotScore !== null && lastPostId !== null) {
    feedQuery = feedQuery.startAfter(lastHotScore, lastPostId);
  }

  // Apply limit
  feedQuery = feedQuery.limit(limit);

  // Execute query
  const snapshot = await feedQuery.get();
  const posts = snapshot.docs.map(doc => ({
    id: doc.id,
    ...doc.data()
  }));

  return {
    posts,
    lastHotScore: posts.length > 0 ? posts[posts.length - 1].hotScore : null,
    lastPostId: posts.length > 0 ? posts[posts.length - 1].id : null
  };
}

// Get alt feed (global, like Reddit's r/All)
async function getAltFeed(limit, lastHotScore, lastPostId) {
  // Query the global alt posts collection
  let feedQuery = firestore
    .collection('altPosts')
    .orderBy('hotScore', 'desc');

  // Apply pagination
  if (lastHotScore !== null && lastPostId !== null) {
    feedQuery = feedQuery.startAfter(lastHotScore, lastPostId);
  }

  // Apply limit
  feedQuery = feedQuery.limit(limit);

  // Execute query
  const snapshot = await feedQuery.get();
  const posts = snapshot.docs.map(doc => ({
    id: doc.id,
    ...doc.data()
  }));

  return {
    posts,
    lastHotScore: posts.length > 0 ? posts[posts.length - 1].hotScore : null,
    lastPostId: posts.length > 0 ? posts[posts.length - 1].id : null
  };
}

// Get herd-specific feed
async function getHerdFeed(herdId, limit, lastHotScore, lastPostId) {
  let feedQuery = firestore
    .collection('herdPosts')
    .doc(herdId)
    .collection('posts')
    .orderBy('hotScore', 'desc');

  // Apply pagination
  if (lastHotScore !== null && lastPostId !== null) {
    feedQuery = feedQuery.startAfter(lastHotScore, lastPostId);
  }

  // Apply limit
  feedQuery = feedQuery.limit(limit);

  // Execute query
  const snapshot = await feedQuery.get();
  const posts = snapshot.docs.map(doc => ({
    id: doc.id,
    ...doc.data()
  }));

  return {
    posts,
    lastHotScore: posts.length > 0 ? posts[posts.length - 1].hotScore : null,
    lastPostId: posts.length > 0 ? posts[posts.length - 1].id : null
  };
}

/**
 * Scheduled job to update hot scores for recent posts
 * Runs every hour to keep scores current
 */
exports.updateHotScores = onSchedule(
  "every 60 minutes",
  async (event) => {
    // Only process posts from the last 7 days
    const oneWeekAgo = new Date();
    oneWeekAgo.setDate(oneWeekAgo.getDate() - 7);

    try {
      // Query for posts with significant engagement
      const postsQuery = firestore
        .collection('posts')
        .where('createdAt', '>', oneWeekAgo)
        .where('likeCount', '>', 0) // Only posts with some engagement
        .limit(500); // Process in chunks

      const postsSnapshot = await postsQuery.get();

      if (postsSnapshot.empty) {
        logger.info('No posts found for hot score update');
        return null;
      }

      logger.info(`Updating hot scores for ${postsSnapshot.size} posts`);

      // Batch update
      const batch = firestore.batch();

      for (const doc of postsSnapshot.docs) {
        const postData = doc.data();
        const netVotes = postData.likeCount - (postData.dislikeCount || 0);

        const updatedHotScore = hotAlgorithm.calculateHotScore(
          netVotes,
          postData.createdAt.toDate()
        );

        // Only update if score has changed significantly
        if (!postData.hotScore || Math.abs(postData.hotScore - updatedHotScore) > 0.001) {
          batch.update(doc.ref, { hotScore: updatedHotScore });
        }
      }

      await batch.commit();
      logger.info('Hot score update completed successfully');
      return null;
    } catch (error) {
      logger.error('Error updating hot scores:', error);
      throw error;
    }
  }
);

/**
 * Update user feed when a follow/unfollow action occurs
 */
exports.handleFollowAction = onDocumentCreated(
  "followers/{followedId}/userFollowers/{followerId}",
  async (event) => {
    const followedId = event.params.followedId;
    const followerId = event.params.followerId;

    try {
      // When someone follows a user, add the followed user's recent public posts to follower's feed
      const recentPostsQuery = firestore
        .collection('posts')
        .where('authorId', '==', followedId)
        .where('isAlt', '==', false) // Only public posts
        .orderBy('createdAt', 'desc')
        .limit(20); // Limit to recent posts

      const postsSnapshot = await recentPostsQuery.get();

      if (postsSnapshot.empty) {
        logger.info(`No public posts found for user ${followedId}`);
        return null;
      }

      // Batch add posts to follower's feed
      const batch = firestore.batch();

      for (const doc of postsSnapshot.docs) {
        const postData = doc.data();

        // Add feedType metadata
        const enhancedPostData = {
          ...postData,
          feedType: 'public',
          hotScore: postData.hotScore || hotAlgorithm.calculateHotScore(
            postData.likeCount - (postData.dislikeCount || 0),
            postData.createdAt.toDate()
          )
        };

        const feedRef = firestore
          .collection('userFeeds')
          .doc(followerId)
          .collection('feed')
          .doc(doc.id);

        batch.set(feedRef, enhancedPostData);
      }

      await batch.commit();
      logger.info(`Added ${postsSnapshot.size} posts to feed of user ${followerId}`);
      return null;
    } catch (error) {
      logger.error(`Error handling follow action (${followerId} → ${followedId}):`, error);
      throw error;
    }
  }
);

/**
 * Clean up user's feed when they unfollow someone
 */
exports.handleUnfollowAction = onDocumentDeleted(
  "followers/{followedId}/userFollowers/{followerId}",
  async (event) => {
    const followedId = event.params.followedId;
    const followerId = event.params.followerId;

    try {
      // Query for the unfollowed user's posts in follower's feed
      const feedQuery = firestore
        .collection('userFeeds')
        .doc(followerId)
        .collection('feed')
        .where('authorId', '==', followedId)
        .where('feedType', '==', 'public');

      const feedSnapshot = await feedQuery.get();

      if (feedSnapshot.empty) {
        logger.info(`No posts from ${followedId} found in ${followerId}'s feed`);
        return null;
      }

      // Batch delete posts
      const batch = firestore.batch();

      for (const doc of feedSnapshot.docs) {
        batch.delete(doc.ref);
      }

      await batch.commit();
      logger.info(`Removed ${feedSnapshot.size} posts from ${followerId}'s feed`);
      return null;
    } catch (error) {
      logger.error(`Error handling unfollow action (${followerId} → ${followedId}):`, error);
      throw error;
    }
  }
);

/**
 * Handle alt connection creation - add alt posts to new connection's feed
 */
exports.handleAltConnection = onDocumentCreated(
  "altConnections/{userId}/userConnections/{connectionId}",
  async (event) => {
    const userId = event.params.userId;
    const connectionId = event.params.connectionId;

    try {
      // Add recent alt posts to the connection's feed
      const recentAltPostsQuery = firestore
        .collection('posts')
        .where('authorId', '==', userId)
        .where('isAlt', '==', true)
        .orderBy('createdAt', 'desc')
        .limit(20);

      const postsSnapshot = await recentAltPostsQuery.get();

      if (postsSnapshot.empty) {
        logger.info(`No alt posts found for user ${userId}`);
        return null;
      }

      // Batch add posts to connection's feed
      const batch = firestore.batch();

      for (const doc of postsSnapshot.docs) {
        const postData = doc.data();

        const enhancedPostData = {
          ...postData,
          feedType: 'alt',
          hotScore: postData.hotScore || hotAlgorithm.calculateHotScore(
            postData.likeCount - (postData.dislikeCount || 0),
            postData.createdAt.toDate()
          )
        };

        const feedRef = firestore
          .collection('userFeeds')
          .doc(connectionId)
          .collection('feed')
          .doc(doc.id);

        batch.set(feedRef, enhancedPostData);
      }

      await batch.commit();
      logger.info(`Added ${postsSnapshot.size} alt posts to feed of user ${connectionId}`);
      return null;
    } catch (error) {
      logger.error(`Error handling alt connection (${userId} → ${connectionId}):`, error);
      throw error;
    }
  }
);

/**
 * Handle alt connection removal - remove alt posts from feed
 */
exports.handleAltConnectionRemoval = onDocumentDeleted(
  "altConnections/{userId}/userConnections/{connectionId}",
  async (event) => {
    const userId = event.params.userId;
    const connectionId = event.params.connectionId;

    try {
      // Remove alt posts from the connection's feed
      const feedQuery = firestore
        .collection('userFeeds')
        .doc(connectionId)
        .collection('feed')
        .where('authorId', '==', userId)
        .where('feedType', '==', 'alt');

      const feedSnapshot = await feedQuery.get();

      if (feedSnapshot.empty) {
        logger.info(`No alt posts from ${userId} found in ${connectionId}'s feed`);
        return null;
      }

      // Batch delete posts
      const batch = firestore.batch();

      for (const doc of feedSnapshot.docs) {
        batch.delete(doc.ref);
      }

      await batch.commit();
      logger.info(`Removed ${feedSnapshot.size} alt posts from ${connectionId}'s feed`);
      return null;
    } catch (error) {
      logger.error(`Error handling alt connection removal (${userId} → ${connectionId}):`, error);
      throw error;
    }
  }
);

/**
 * Add/remove user from herd feed when joining/leaving a herd
 */
exports.handleHerdMembership = onDocumentCreated(
  "herdMembers/{herdId}/members/{userId}",
  async (event) => {
    const herdId = event.params.herdId;
    const userId = event.params.userId;

    try {
      // Query recent herd posts
      const herdPostsQuery = firestore
        .collection('posts')
        .where('herdId', '==', herdId)
        .orderBy('createdAt', 'desc')
        .limit(50);

      const postsSnapshot = await herdPostsQuery.get();

      if (postsSnapshot.empty) {
        logger.info(`No posts found for herd ${herdId}`);
        return null;
      }

      // Add herd posts to user's feed
      const batch = firestore.batch();

      for (const doc of postsSnapshot.docs) {
        const postData = doc.data();

        const enhancedPostData = {
          ...postData,
          feedType: 'herd',
          hotScore: postData.hotScore || hotAlgorithm.calculateHotScore(
            postData.likeCount - (postData.dislikeCount || 0),
            postData.createdAt.toDate()
          )
        };

        const feedRef = firestore
          .collection('userFeeds')
          .doc(userId)
          .collection('feed')
          .doc(doc.id);

        batch.set(feedRef, enhancedPostData);
      }

      await batch.commit();
      logger.info(`Added ${postsSnapshot.size} herd posts to feed of user ${userId}`);
      return null;
    } catch (error) {
      logger.error(`Error handling herd membership (${userId} joins ${herdId}):`, error);
      throw error;
    }
  }
);

/**
 * Clean up herd posts from user's feed when leaving a herd
 */
exports.handleHerdLeave = onDocumentDeleted(
  "herdMembers/{herdId}/members/{userId}",
  async (event) => {
    const herdId = event.params.herdId;
    const userId = event.params.userId;

    try {
      // Query for herd posts in user's feed
      const feedQuery = firestore
        .collection('userFeeds')
        .doc(userId)
        .collection('feed')
        .where('herdId', '==', herdId);

      const feedSnapshot = await feedQuery.get();

      if (feedSnapshot.empty) {
        logger.info(`No posts from herd ${herdId} found in ${userId}'s feed`);
        return null;
      }

      // Batch delete posts
      const batch = firestore.batch();

      for (const doc of feedSnapshot.docs) {
        batch.delete(doc.ref);
      }

      await batch.commit();
      logger.info(`Removed ${feedSnapshot.size} herd posts from ${userId}'s feed`);
      return null;
    } catch (error) {
      logger.error(`Error handling herd leave (${userId} leaves ${herdId}):`, error);
      throw error;
    }
  }
);

/**
 * Get trending posts for discovery
 */
exports.getTrendingPosts = onCall(async (request) => {
  const {
    limit = 10,
    postType = 'all' // 'all', 'public', 'alt'
  } = request.data;

  try {
    // Get posts from the last 3 days with high engagement
    const threeDaysAgo = new Date();
    threeDaysAgo.setDate(threeDaysAgo.getDate() - 3);

    let postsQuery = firestore.collection('posts')
      .where('createdAt', '>', threeDaysAgo)
      .orderBy('createdAt', 'desc'); // Recent first

    // Apply post type filter if specified
    if (postType === 'public') {
      postsQuery = postsQuery.where('isAlt', '==', false);
    } else if (postType === 'alt') {
      postsQuery = postsQuery.where('isAlt', '==', true);
    }

    // Get more posts than needed to allow for sorting
    postsQuery = postsQuery.limit(limit * 3);

    const postsSnapshot = await postsQuery.get();

    if (postsSnapshot.empty) {
      return { posts: [] };
    }

    // Convert to array and sort by hot algorithm
    let posts = postsSnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));

    // Sort using a more aggressive decay factor to prioritize recent content
    posts = hotAlgorithm.sortPosts(posts, 0.5);

    // Return top posts
    return { posts: posts.slice(0, limit) };
  } catch (error) {
    logger.error('Error getting trending posts:', error);
    throw new HttpsError('internal', `Failed to get trending posts: ${error.message}`);
  }
});