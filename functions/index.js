const functions = require('firebase-functions');
const { onDocumentCreated, onDocumentDeleted, onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { logger } = require("firebase-functions");
const { getFirestore } = require('firebase-admin/firestore');
const admin = require("firebase-admin");

admin.initializeApp();
const firestore = admin.firestore();
const db = getFirestore();

const notificationFunctionsFactory = require('./notification_functions');
const notificationFunctions = notificationFunctionsFactory(admin);


/**
 * Helper function to update hot scores in user feeds
 * @param {Array} updatedPosts - Array of objects containing post info
 */
async function updateUserFeedsForPosts(updatedPosts) {
  if (updatedPosts.length === 0) return;

  const MAX_BATCH_SIZE = 500;
  let batch = firestore.batch();
  let operationCount = 0;

  for (const post of updatedPosts) {
    // Find all user feeds containing this post
    let userFeedsQuery = firestore
      .collectionGroup("feed")
      .where("id", "==", post.id)
      .where("sourceCollection", "==", post.sourceCollection);

    // Add herdId filter if applicable
    if (post.sourceCollection === 'herdPosts' && post.herdId) {
      userFeedsQuery = userFeedsQuery.where("herdId", "==", post.herdId);
    }

    const feedEntries = await userFeedsQuery.select().get();

    if (feedEntries.empty) {
      logger.info(`No user feed entries found for ${post.sourceCollection} ${post.id}`);
      continue;
    }

    logger.info(`Updating hot score for ${post.sourceCollection} ${post.id} in ${feedEntries.size} user feeds`);

    for (const doc of feedEntries.docs) {
      batch.update(doc.ref, { hotScore: post.hotScore });
      operationCount++;

      if (operationCount >= MAX_BATCH_SIZE) {
        await batch.commit();
        batch = firestore.batch();
        operationCount = 0;
      }
    }
  }

  if (operationCount > 0) {
    await batch.commit();
  }

  logger.info(`User feeds updated with new hot scores for ${updatedPosts.length} posts`);
}

[
  { path: "posts/{postId}", sourceCollection: "posts" },
  { path: "altPosts/{postId}", sourceCollection: "altPosts" },
  { path: "herdPosts/{herdId}/posts/{postId}", sourceCollection: "herdPosts" }
].forEach(({ path, sourceCollection }) => {
  exports[`syncHotScore_${sourceCollection}`] = onDocumentUpdated(
    path,
    async (event) => {
      const postId = event.params.postId;
      const after = event.data.after.data();
      const newHotScore = after.hotScore;
      logger.info(`Syncing hotScore=${newHotScore} for ${sourceCollection}/${postId}`);

      // Find and update all feed entries
      const feeds = await admin
        .firestore()
        .collectionGroup("feed")
        .where("id", "==", postId)
        .where("sourceCollection", "==", sourceCollection)
        .get();

      if (feeds.empty) {
        logger.info(`No feed docs found for ${postId} in ${sourceCollection}`);
        return;
      }

      const batch = admin.firestore().batch();
      feeds.forEach(doc => {
        batch.update(doc.ref, { hotScore: newHotScore });
      });
      await batch.commit();
      logger.info(`Updated ${feeds.size} feed docs for ${postId}`);
    }
  );
});


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



// Get public feed (personalized for each user)
async function getPublicFeed(userId, limit, lastHotScore, lastPostId) {
  try {
    // STEP 1: Query the userFeeds to get the ordered post IDs
    let feedQuery = firestore
      .collection('userFeeds')
      .doc(userId)
      .collection('feed')
      .where('feedType', '==', 'public')
      .orderBy('hotScore', 'desc')
      .orderBy(admin.firestore.FieldPath.documentId(), 'asc');

    // Apply pagination
    if (lastHotScore !== null && lastPostId !== null) {
      logger.info(`Attempting to paginate public feed with lastHotScore: ${lastHotScore}, lastPostId: ${lastPostId}`);
      // Use startAfter with an array of values to match the orderBy fields
      feedQuery = feedQuery.startAfter(lastHotScore, lastPostId);
    }

    // Apply limit
    feedQuery = feedQuery.limit(limit);

    // Execute query to get feed entries
    const feedSnapshot = await feedQuery.get();

    if (feedSnapshot.empty) {
      logger.info(`No public feed entries found for user: ${userId}`);
      return { posts: [], lastHotScore: null, lastPostId: null };
    }

    // Extract post IDs and hot scores from feed entries
    const postIds = [];
    const hotScoreMap = {};

    feedSnapshot.docs.forEach(doc => {
      postIds.push(doc.id);
      const data = doc.data();
      hotScoreMap[doc.id] = data.hotScore || 0;
    });

    logger.info(`Found ${postIds.length} public feed entries for user: ${userId}`);

    // STEP 2: Query the source of truth for complete post data
    // Split into chunks of 10 for whereIn query limitation
    const chunkedResults = [];

    for (let i = 0; i < postIds.length; i += 10) {
      const chunk = postIds.slice(i, i + 10);

      const postsQuery = firestore
        .collection('posts')
        .where(admin.firestore.FieldPath.documentId(), 'in', chunk);

      const postsSnapshot = await postsQuery.get();

      postsSnapshot.docs.forEach(doc => {
        chunkedResults.push({
          id: doc.id,
          ...doc.data(),
          // Use hot score from user feed to maintain ordering
          hotScore: hotScoreMap[doc.id]
        });
      });
    }


    const posts = chunkedResults.sort((a, b) => b.hotScore - a.hotScore);

    const userInteractions = await getUserInteractionsForPosts(userId, posts.map(post => post.id));

    // Add user-specific data to each post
    const enrichedPosts = posts.map(post => {
      return {
        ...post,
        isLiked: userInteractions[post.id]?.isLiked || false,
        isDisliked: userInteractions[post.id]?.isDisliked || false
      };
    });

    logger.info(`Retrieved ${posts.length} complete posts for public feed`);

    // Return the results with pagination info
    return {
      posts: enrichedPosts,
      lastHotScore: posts.length > 0 ? posts[posts.length - 1].hotScore : null,
      lastPostId: posts.length > 0 ? posts[posts.length - 1].id : null,
      hasMorePosts: posts.length >= limit
    };
  } catch (error) {
    logger.error(`Error getting public feed: ${error}`);
    throw error;
  }
}

// Get alt feed (global, like Reddit's r/All)
async function getAltFeed(limit, lastHotScore, lastPostId) {
  try {
    // Query the global alt posts collection
    let feedQuery = firestore
      .collection('altPosts')
      .orderBy('hotScore', 'desc')
      .orderBy(admin.firestore.FieldPath.documentId(), 'asc');

    // Apply pagination
    if (lastHotScore !== null && lastPostId !== null) {
      logger.info(`Attempting to paginate alt feed with lastHotScore: ${lastHotScore}, lastPostId: ${lastPostId}`);
      // Use startAfter with an array of values to match the orderBy fields 
      feedQuery = feedQuery.startAt(lastHotScore, lastPostId);
    }

    // Apply limit
    feedQuery = feedQuery.limit(limit);

    // Execute query to get complete alt posts
    const snapshot = await feedQuery.get();

    if (snapshot.empty) {
      logger.info('No alt posts found');
      return { posts: [], lastHotScore: null, lastPostId: null };
    }

    const posts = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));

    logger.info(`Retrieved ${posts.length} alt posts`);

    return {
      posts,
      lastHotScore: posts.length > 0 ? posts[posts.length - 1].hotScore : null,
      lastPostId: posts.length > 0 ? posts[posts.length - 1].id : null,
      hasMorePosts: posts.length >= limit
    };
  } catch (error) {
    logger.error(`Error getting alt feed: ${error}`);
    throw error;
  }
}

// Get herd-specific feed
async function getHerdFeed(herdId, limit, lastHotScore, lastPostId) {
  let feedQuery = firestore
    .collection('herdPosts')
    .doc(herdId)
    .collection('posts')
    .orderBy('hotScore', 'desc')
    .orderBy(admin.firestore.FieldPath.documentId(), 'asc');

  // Apply pagination
  if (lastHotScore !== null && lastPostId !== null) {
    feedQuery = feedQuery.startAt(lastHotScore, lastPostId);
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
    lastPostId: posts.length > 0 ? posts[posts.length - 1].id : null,
    hasMorePosts: posts.length >= limit
  };
}

async function getUserInteractionsForPosts(userId, postIds) {
  // Batch get user interactions for all posts
  const interactionsRef = firestore.collection('userInteractions').doc(userId);
  const interactionsSnapshot = await interactionsRef.get();

  if (!interactionsSnapshot.exists) {
    return {};
  }

  const interactions = interactionsSnapshot.data() || {};
  const result = {};

  // Filter to just the posts we care about
  postIds.forEach(postId => {
    if (interactions[postId]) {
      result[postId] = interactions[postId];
    }
  });

  return result;
}

exports.onNewFollower = notificationFunctions.onNewFollower;
exports.onNewPost = notificationFunctions.onNewPost;
exports.onPostLike = notificationFunctions.onPostLike;
exports.onNewComment = notificationFunctions.onNewComment;
exports.onConnectionRequest = notificationFunctions.onConnectionRequest;
exports.onConnectionAccepted = notificationFunctions.onConnectionAccepted;
exports.markNotificationsAsRead = notificationFunctions.markNotificationsAsRead;
exports.deleteNotifications = notificationFunctions.deleteNotifications;