const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { onDocumentCreated, onDocumentDeleted, onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { logger } = require("firebase-functions");

admin.initializeApp();
const firestore = admin.firestore();

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

  // Sorting method with more sophisticated ranking
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





exports.distributePost = onDocumentCreated(
  "posts/{postId}",
  async (event) => {
    const postId = event.params.postId;
    const postData = event.data.data();

    // Validate post data
    if (!postData || !postData.authorId) {
      console.error(`Invalid post data for ID: ${postId}`);
      return null;
    }

    // Compute initial hot score
    const initialHotScore = hotAlgorithm.calculateHotScore(
      0, // New posts start with 0 net votes
      postData.createdAt ? postData.createdAt.toDate() : new Date()
    );

    // Determine feed types based on post attributes
    const feedTypes = [
      postData.isAlt ? 'altFeeds' : 'publicFeeds',
      ...(postData.herdId ? [`herdFeeds/${postData.herdId}`] : [])
    ];

    // Batch write to multiple feed collections
    const writeBatches = feedTypes.map(feedType => {
      const batch = admin.firestore().batch();

      // Determine followers/members based on feed type
      const followersRef = postData.isAlt
        ? admin.firestore().collection('altConnections').doc(postData.authorId).collection('connections')
        : admin.firestore().collection('followers').doc(postData.authorId).collection('userFollowers');

      // Add hot score to post data for efficient sorting
      const enhancedPostData = {
        ...postData,
        hotScore: initialHotScore,
        feedType: feedType.split('/')[0],
        ...(postData.herdId ? { herdId: postData.herdId } : {})
      };

      return { feedType, followersRef, enhancedPostData, batch };
    });

    // Batch processing for each feed type
    for (const { feedType, followersRef, enhancedPostData, batch } of writeBatches) {
      const followersSnapshot = await followersRef.get();

      followersSnapshot.forEach(followerDoc => {
        const feedRef = admin.firestore()
          .collection('userFeeds')
          .doc(followerDoc.id)
          .collection(feedType)
          .doc(postId);

        batch.set(feedRef, enhancedPostData);
      });

      await batch.commit();
    }

    return null;
  }
);


/**
 * Cloud Function triggered when a new alt post is created
 * Distributes the post to the feeds of all alt connections
 */
exports.distributeAltPost = onDocumentCreated(
    "posts/{postId}",
    async (event) => {
        const postId = event.params.postId;
        const postData = event.data.data();

        if (!postData) {
            console.error(`No post data found for ID: ${postId}`);
            return null;
        }

        const authorId = postData.authorId;
        if (!authorId) {
            console.error(`No author ID found for post: ${postId}`);
            return null;
        }

        const initialHotScore = hotAlgorithm.calculateHotScore(
          0, // New posts have 0 net votes
          postData.createdAt ? postData.createdAt.toDate() : new Date()
        );

        postData.hotScore = initialHotScore;

        await firestore.collection("userFeeds").collection(userId).doc(postId).update({
            hotScore: initialHotScore
        });

        try {
            console.log(`Starting distribution of alt post ${postId} by author ${authorId}`);

            // Get all alt connections of the post author
            const connectionsSnapshot = await firestore
                .collection("altConnections")
                .doc(authorId)
                .collection("userConnections")
                .get();

            if (connectionsSnapshot.empty) {
                console.log(`No alt connections found for user ${authorId}`);
                return null;
            }

            // Create a batch write to efficiently handle multiple writes
            let currentBatch = firestore.batch();
            let operationCount = 0;
            const MAX_BATCH_SIZE = 500; // Firestore batch limit

            console.log(`Distributing alt post to ${connectionsSnapshot.size} connections`);

            // Add the post to each connection's alt feed
            for (const connectionDoc of connectionsSnapshot.docs) {
                const connectionId = connectionDoc.id;

                // Create reference to the connection's alt feed
                const altFeedRef = firestore
                    .collection("userFeeds")
                    .doc(connectionId)
                    .collection("altFeed")
                    .doc(postId);

                // Add post to connection's alt feed
                currentBatch.set(altFeedRef, postData);
                operationCount++;

                // If we've reached the batch limit, commit and create a new batch
                if (operationCount >= MAX_BATCH_SIZE) {
                    await currentBatch.commit();
                    console.log(`Committed batch of ${operationCount} operations`);
                    currentBatch = firestore.batch();
                    operationCount = 0;
                }
            }

            // Commit any remaining operations
            if (operationCount > 0) {
                await currentBatch.commit();
                console.log(`Committed final batch of ${operationCount} operations`);
            }

            console.log(`Successfully distributed alt post ${postId} to all connections`);
            return null;
        } catch (error) {
            console.error(`Error distributing alt post ${postId}:`, error);
            throw error;
        }
    });

/**
 * Function to handle post deletion and remove it from all feeds
 */
exports.removeDeletedPost = onDocumentDeleted(
    "posts/{postId}",
    async (event) => {
        const postId = event.params.postId;
        const postData = event.data.data();

        if (!postData) {
            console.error(`No post data found for deleted ID: ${postId}`);
            return null;
        }

        const authorId = postData.authorId;
        if (!authorId) {
            console.error(`No author ID found for deleted post: ${postId}`);
            return null;
        }

        try {
            console.log(`Removing deleted post ${postId} from feeds`);

            // Get all followers of the post author
            const followersSnapshot = await firestore
                .collection("followers")
                .doc(authorId)
                .collection("userFollowers")
                .get();

            if (followersSnapshot.empty) {
                console.log(`No followers found for user ${authorId}`);
                return null;
            }

            // Create batches to handle deletions
            let currentBatch = firestore.batch();
            let operationCount = 0;
            const MAX_BATCH_SIZE = 500;

            // Remove the post from each follower's feed
            for (const followerDoc of followersSnapshot.docs) {
                const followerId = followerDoc.id;

                const feedRef = firestore
                    .collection("feeds")
                    .doc(followerId)
                    .collection("userFeed")
                    .doc(postId);

                currentBatch.delete(feedRef);
                operationCount++;

                if (operationCount >= MAX_BATCH_SIZE) {
                    await currentBatch.commit();
                    currentBatch = firestore.batch();
                    operationCount = 0;
                }
            }

            if (operationCount > 0) {
                await currentBatch.commit();
            }

            console.log(`Successfully removed deleted post ${postId} from all feeds`);
            return null;
        } catch (error) {
            console.error(`Error removing deleted post ${postId}:`, error);
            throw error;
        }
    });

/**
 * Function to handle alt post deletion
 */
exports.removeDeletedAltPost = onDocumentDeleted(
    "globalAltPosts/{postId}",
    async (event) => {
        const postId = event.params.postId;
        const postData = event.data.data();

        if (!postData) {
            console.error(`No post data found for deleted ID: ${postId}`);
            return null;
        }

        const authorId = postData.authorId;
        if (!authorId) {
            console.error(`No author ID found for deleted post: ${postId}`);
            return null;
        }

        try {
            console.log(`Removing deleted alt post ${postId} from feeds`);

            // Get all alt connections of the post author
            const connectionsSnapshot = await firestore
                .collection("altConnections")
                .doc(authorId)
                .collection("userConnections")
                .get();

            if (connectionsSnapshot.empty) {
                console.log(`No alt connections found for user ${authorId}`);
                return null;
            }

            // Create batches to handle deletions
            let currentBatch = firestore.batch();
            let operationCount = 0;
            const MAX_BATCH_SIZE = 500;

            // Remove the post from each connection's alt feed
            for (const connectionDoc of connectionsSnapshot.docs) {
                const connectionId = connectionDoc.id;

                const altFeedRef = firestore
                    .collection("altFeeds")
                    .doc(connectionId)
                    .collection("altFeed")
                    .doc(postId);

                currentBatch.delete(altFeedRef);
                operationCount++;

                if (operationCount >= MAX_BATCH_SIZE) {
                    await currentBatch.commit();
                    currentBatch = firestore.batch();
                    operationCount = 0;
                }
            }

            if (operationCount > 0) {
                await currentBatch.commit();
            }

            console.log(`Successfully removed deleted alt post ${postId} from all alt feeds`);
            return null;
        } catch (error) {
            console.error(`Error removing deleted alt post ${postId}:`, error);
            throw error;
        }
    });

/**
 * Cloud Function to handle post likes
 * - Toggles like status
 * - Removes dislike if exists
 * - Updates post like/dislike counts
 * - Updates user points
 */
//exports.handlePostLike = onCall(async (request) => {
//    const idToken = request.data.idToken;
//    if (!idToken) {
//        throw new functions.https.HttpsError('unauthenticated', 'User must be logged in');
//    }
//
//    const userId = request.auth.uid;
//    const herdId = request.data.herdId;
//    const postId = request.data.postId;
//    const isAlt = request.data.isAlt || false;
//
//    if (!postId) {
//        throw new HttpsError('invalid-argument', 'Post ID is required');
//    }
//
//    try {
//        const decodedToken = await admin.auth().verifyIdToken(idToken);
//        // Start a Firestore transaction to ensure atomic updates
//        return await firestore.runTransaction(async (transaction) => {
//            // Determine which collection to use based on post type
//            let postRef;
//
//            if (herdId) {
//                postRef = firestore.collection('herdPosts').doc(herdId).collection('posts').doc(postId);
//            }
//            if (isAlt) {
//                postRef = firestore.collection('globalAltPosts').doc(postId);
//            }
//            else {
//                postRef = firestore.collection('posts').doc(postId);
//            }
//
//            const postDoc = await transaction.get(postRef);
//
//            if (!postDoc.exists) {
//                throw new HttpsError('not-found', 'Post not found');
//            }
//
//            // Get post data
//            const postData = postDoc.data();
//            const authorId = postData.authorId;
//
//            // References to like and dislike collections
//            const likeRef = firestore.collection('likes').doc(postId).collection('postLikes').doc(userId);
//            const dislikeRef = firestore.collection('dislikes').doc(postId).collection('postDislikes').doc(userId);
//
//            // Get current like/dislike state
//            const likeDoc = await transaction.get(likeRef);
//            const dislikeDoc = await transaction.get(dislikeRef);
//
//            const isLiked = likeDoc.exists;
//            const isDisliked = dislikeDoc.exists;
//
//            // Determine update operations
//            let likeChange = 0;
//            let dislikeChange = 0;
//            let pointChange = 0;
//
//            // Handle like toggle
//            if (isLiked) {
//                // Unlike: remove like
//                transaction.delete(likeRef);
//                likeChange = -1;
//                pointChange = -1;
//            } else {
//                // Like: add like
//                transaction.set(likeRef, { timestamp: admin.firestore.FieldValue.serverTimestamp() });
//                likeChange = 1;
//                pointChange = 1;
//
//                // If was disliked, remove dislike
//                if (isDisliked) {
//                    transaction.delete(dislikeRef);
//                    dislikeChange = -1;
//                    pointChange += 1; // +1 for removing dislike
//                }
//            }
//
//            // Update post like/dislike counts
//            transaction.update(postRef, {
//                likeCount: admin.firestore.FieldValue.increment(likeChange),
//                dislikeCount: admin.firestore.FieldValue.increment(dislikeChange)
//            });
//
//            // Update author's points (only if not toggling own post)
//            if (authorId !== userId && pointChange !== 0) {
//                const authorRef = firestore.collection('users').doc(authorId);
//                transaction.update(authorRef, {
//                    userPoints: admin.firestore.FieldValue.increment(pointChange)
//                });
//            }
//
//            // Return the state for client sync
//            return {
//                isLiked: !isLiked,
//                isDisliked: false,
//                likeCount: (postData.likeCount || 0) + likeChange,
//                dislikeCount: (postData.dislikeCount || 0) + dislikeChange,
//                successful: true
//            };
//        });
//    } catch (error) {
//        console.error('Error handling like:', error);
//        throw new HttpsError('internal', 'Failed to process like');
//    }
//});
//
///**
// * Cloud Function to handle post dislikes
// * - Toggles dislike status
// * - Removes like if exists
// * - Updates post like/dislike counts
// * - Updates user points
// */
//exports.handlePostDislike = onCall(async (request) => {
//    const idToken = request.data.idToken;
//    if (!idToken) {
//        throw new functions.https.HttpsError('unauthenticated', 'User must be logged in');
//    }
//
//    const userId = request.auth.uid;
//    const herdId = request.data.herdId;
//    const postId = request.data.postId;
//    const isAlt = request.data.isAlt || false;
//
//
//    if (!postId) {
//        throw new HttpsError('invalid-argument', 'Post ID is required');
//    }
//
//    try {
//        const decodedToken = await admin.auth().verifyIdToken(idToken);
//        // Start a Firestore transaction to ensure atomic updates
//        return await firestore.runTransaction(async (transaction) => {
//            let postRef;
//
//            if (herdId) {
//                postRef = firestore.collection('herdPosts').doc(herdId).collection('posts').doc(postId);
//            }
//            if (isAlt) {
//                postRef = firestore.collection('globalAltPosts').doc(postId);
//            }
//            else {
//                postRef = firestore.collection('posts').doc(postId);
//            }
//
//            const postDoc = await transaction.get(postRef);
//
//            if (!postDoc.exists) {
//                throw new HttpsError('not-found', 'Post not found');
//            }
//
//            // Get post data
//            const postData = postDoc.data();
//            const authorId = postData.authorId;
//
//            // References to like and dislike collections
//            const likeRef = firestore.collection('likes').doc(postId).collection('postLikes').doc(userId);
//            const dislikeRef = firestore.collection('dislikes').doc(postId).collection('postDislikes').doc(userId);
//
//            // Get current like/dislike state
//            const likeDoc = await transaction.get(likeRef);
//            const dislikeDoc = await transaction.get(dislikeRef);
//
//            const isLiked = likeDoc.exists;
//            const isDisliked = dislikeDoc.exists;
//
//            // Determine update operations
//            let likeChange = 0;
//            let dislikeChange = 0;
//            let pointChange = 0;
//
//            // Handle dislike toggle
//            if (isDisliked) {
//                // Undislike: remove dislike
//                transaction.delete(dislikeRef);
//                dislikeChange = -1;
//                pointChange = 1; // +1 for removing dislike
//            } else {
//                // Dislike: add dislike
//                transaction.set(dislikeRef, { timestamp: admin.firestore.FieldValue.serverTimestamp() });
//                dislikeChange = 1;
//                pointChange = -1;
//
//                // If was liked, remove like
//                if (isLiked) {
//                    transaction.delete(likeRef);
//                    likeChange = -1;
//                    pointChange -= 1; // -1 for removing like
//                }
//            }
//
//            // Update post like/dislike counts
//            transaction.update(postRef, {
//                likeCount: admin.firestore.FieldValue.increment(likeChange),
//                dislikeCount: admin.firestore.FieldValue.increment(dislikeChange)
//            });
//
//            // Update author's points (only if not toggling own post)
//            if (authorId !== userId && pointChange !== 0) {
//                const authorRef = firestore.collection('users').doc(authorId);
//                transaction.update(authorRef, {
//                    userPoints: admin.firestore.FieldValue.increment(pointChange)
//                });
//            }
//
//            // Return the state for client sync
//            return {
//                isLiked: false,
//                isDisliked: !isDisliked,
//                likeCount: (postData.likeCount || 0) + likeChange,
//                dislikeCount: (postData.dislikeCount || 0) + dislikeChange,
//                successful: true
//            };
//        });
//    } catch (error) {
//        console.error('Error handling dislike:', error);
//        throw new HttpsError('internal', 'Failed to process dislike');
//    }
//});

/**
 * Scheduled function to calculate and update hot scores for all posts
 * Runs every 15 minutes to keep scores current without overloading your Firebase quota
 */
exports.updateHotScores = onSchedule(
  "every 15 minutes",
  async (event) => {
    const oneWeekAgo = new Date();
    oneWeekAgo.setDate(oneWeekAgo.getDate() - 7);

    // Collections to update
    const collectionsToUpdate = [
      { name: 'posts', alt: false },
      { name: 'globalAltPosts', alt: true },
      // Add herd post collection
      { name: 'herdPosts', herd: true }
    ];

    for (const collection of collectionsToUpdate) {
      const query = admin.firestore()
        .collection(collection.name)
        .where('createdAt', '>', oneWeekAgo);

      const snapshot = await query.get();

      const updateBatch = admin.firestore().batch();

      snapshot.docs.forEach(doc => {
        const postData = doc.data();
        const netVotes = (postData.likeCount || 0) - (postData.dislikeCount || 0);

        const updatedHotScore = hotAlgorithm.calculateHotScore(
          netVotes,
          postData.createdAt.toDate()
        );

        // Only update if score changed significantly
        if (!postData.hotScore || Math.abs(postData.hotScore - updatedHotScore) > 0.001) {
          updateBatch.update(doc.ref, {
            hotScore: updatedHotScore
          });
        }
      });

      await updateBatch.commit();
    }
  }
);

exports.getFeed = onCall(async (request) => {
  const {
    userId,
    feedType = 'public',
    herdId = null,
    limit = 20,
    lastHotScore = null
  } = request.data;

  // Validate user authentication
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'User must be logged in');
  }

  let feedQuery = admin.firestore()
    .collection('userFeeds')
    .doc(userId)
    .collection(feedType);

  // Add optional herd filter
  if (herdId) {
    feedQuery = feedQuery.where('herdId', '==', herdId);
  }

  // Use hot score for pagination and sorting
  feedQuery = feedQuery
    .orderBy('hotScore', 'desc')
    .limit(limit);

  // Add cursor-based pagination if last hot score provided
  if (lastHotScore) {
    feedQuery = feedQuery.startAfter(lastHotScore);
  }

  const snapshot = await feedQuery.get();
  const posts = snapshot.docs.map(doc => ({
    id: doc.id,
    ...doc.data()
  }));

  return { posts };
});


exports.handlePostInteraction = onCall(async (request) => {
  const {
    postId,
    interactionType,
    isAlt = false
  } = request.data;


  // Validate authentication
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'User must be logged in');
  }

  const userId = request.auth.uid;
  const postRef = admin.firestore()
    .collection(isAlt ? 'globalAltPosts' : 'posts')
    .doc(postId);

  return admin.firestore().runTransaction(async (transaction) => {
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
    const interactionRef = admin.firestore()
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
        admin.firestore.FieldValue.increment(isCurrentlyInteracted ? 1 : -1)
    });

    // Toggle interaction document
    if (isCurrentlyInteracted) {
      transaction.delete(interactionRef);
    } else {
      transaction.set(interactionRef, {
        timestamp: admin.firestore.FieldValue.serverTimestamp()
      });
    }

    // Recompute hot score immediately
    const netVotes = (postData.likeCount || 0) - (postData.dislikeCount || 0);
    const updatedHotScore = hotAlgorithm.calculateHotScore(
      netVotes,
      postData.createdAt.toDate()
    );

    transaction.update(postRef, { hotScore: updatedHotScore });

    return {
      success: true,
      hotScore: updatedHotScore
    };
  });
});

/**
 * Updates hot scores for posts in a single collection
 */
async function updateCollectionHotScores(collectionName, timeThreshold) {
  // Query for recent posts
  const snapshot = await firestore.collection(collectionName)
    .where('createdAt', '>', timeThreshold)
    .get();

  if (snapshot.empty) {
    logger.log(`No recent posts found in ${collectionName}`);
    return 0;
  }

  logger.log(`Processing ${snapshot.size} posts in ${collectionName}`);

  // Use batched writes for efficiency - Firestore limits to 500 ops per batch
  const MAX_BATCH_SIZE = 500;
  let batch = firestore.batch();
  let operationCount = 0;
  let totalUpdated = 0;

  for (const doc of snapshot.docs) {
    const postData = doc.data();

    // Calculate hot score using your existing hotAlgorithm
    const hotScore = hotAlgorithm.calculateHotScore(
      (postData.likeCount || 0) - (postData.dislikeCount || 0),
      postData.createdAt ? postData.createdAt.toDate() : new Date()
    );

    // Only update if score changed significantly or doesn't exist
    if (!postData.hotScore || Math.abs(postData.hotScore - hotScore) > 0.001) {
      batch.update(doc.ref, { hotScore: hotScore });
      operationCount++;
      totalUpdated++;

      // Commit batch if we've reached the limit
      if (operationCount >= MAX_BATCH_SIZE) {
        await batch.commit();
        logger.log(`Committed batch of ${operationCount} operations`);
        batch = firestore.batch();
        operationCount = 0;
      }
    }
  }

  // Commit any remaining operations
  if (operationCount > 0) {
    await batch.commit();
    logger.log(`Committed final batch of ${operationCount} operations`);
  }

  logger.log(`Updated ${totalUpdated} posts in ${collectionName}`);
  return totalUpdated;
}

/**
 * Updates hot scores for all herd posts using a collection group query
 */
async function updateHerdPostsHotScores(timeThreshold) {
  // Use collection group query to get all herd posts
  const herdPostsSnapshot = await firestore.collectionGroup('posts')
    .where('createdAt', '>', timeThreshold)
    .get();

  if (herdPostsSnapshot.empty) {
    logger.log(`No recent herd posts found`);
    return 0;
  }

  logger.log(`Processing ${herdPostsSnapshot.size} herd posts`);

  const MAX_BATCH_SIZE = 500;
  let batch = firestore.batch();
  let operationCount = 0;
  let totalUpdated = 0;

  for (const doc of herdPostsSnapshot.docs) {
    const postData = doc.data();

    // Calculate hot score
    const hotScore = hotAlgorithm.calculateHotScore(
      (postData.likeCount || 0) - (postData.dislikeCount || 0),
      postData.createdAt ? postData.createdAt.toDate() : new Date()
    );

    // Only update if score changed significantly or doesn't exist
    if (!postData.hotScore || Math.abs(postData.hotScore - hotScore) > 0.001) {
      batch.update(doc.ref, { hotScore: hotScore });
      operationCount++;
      totalUpdated++;

      // Commit batch if we've reached the limit
      if (operationCount >= MAX_BATCH_SIZE) {
        await batch.commit();
        logger.log(`Committed batch of ${operationCount} herd post operations`);
        batch = firestore.batch();
        operationCount = 0;
      }
    }
  }

  // Commit any remaining operations
  if (operationCount > 0) {
    await batch.commit();
    logger.log(`Committed final batch of ${operationCount} herd post operations`);
  }

  logger.log(`Updated ${totalUpdated} herd posts`);
  return totalUpdated;
}

/**
 * Cloud Function to calculate and update comment hotness score
 */
exports.updateCommentHotnessScore = onDocumentUpdated(
    "comments/{postId}/postComments/{commentId}",
    async (event) => {
        // Get the new and previous document data
        const newData = event.data.after.data();
        const oldData = event.data.before.data();

        // Only proceed if relevant fields have changed
        if (newData.likeCount === oldData.likeCount &&
            newData.dislikeCount === oldData.dislikeCount) {
            return null;
        }

        try {
            // Calculate hotness score
            const hotnessScore = calculateHotnessScore(newData);

            // Update the document with the new hotness score
            await event.data.after.ref.update({
                hotnessScore: hotnessScore
            });

            console.log(`Updated hotness score for comment ${event.params.commentId}: ${hotnessScore}`);
            return null;
        } catch (error) {
            console.error('Error updating comment hotness score:', error);
            return null;
        }
    }
);

/**
 * Calculate hotness score similar to Reddit's algorithm
 * @param {Object} commentData - Firestore comment document data
 * @returns {number} Calculated hotness score
 */
function calculateHotnessScore(commentData) {
    const likeCount = commentData.likeCount || 0;
    const dislikeCount = commentData.dislikeCount || 0;
    const timestamp = commentData.timestamp ? new Date(commentData.timestamp._seconds * 1000) : new Date();

    // Calculate net votes (likes minus dislikes)
    const netVotes = likeCount - dislikeCount;

    // Use log of absolute net votes to dampen extreme values
    const order = netVotes > 0
        ? Math.log(netVotes)
        : netVotes < 0
        ? -Math.log(-netVotes)
        : 0;

    // Calculate time decay
    const secondsSinceCreation = (new Date() - timestamp) / 1000;
    const decay = 45000; // Tune this value based on your needs

    // Combine order and time decay
    return order + secondsSinceCreation / decay;
}

/**
 * Cloud Function to handle comment likes
 */
exports.handleCommentLike = onCall(async (request) => {
    const userId = request.auth.uid;
    const commentId = request.data.commentId;
    const postId = request.data.postId;
    const isAlt = request.data.isAlt || false;

    if (!commentId) {
        throw new HttpsError('invalid-argument', 'Comment ID is required');
    }

    try {
        return await admin.firestore().runTransaction(async (transaction) => {
        const postId = request.data.postId;
        if (!postId) {
            throw new HttpsError('invalid-argument', 'Post ID is required');
        }
        const commentRef = admin.firestore()
            .collection(isAlt ? 'altComments' : 'comments')
            .doc(postId)
            .collection('postComments')
            .doc(commentId);

            const commentDoc = await transaction.get(commentRef);
            if (!commentDoc.exists) {
                throw new HttpsError('not-found', 'Comment not found');
            }

            const commentData = commentDoc.data();
            const authorId = commentData.authorId;

            // References to like and dislike collections
            const likeRef = admin.firestore()
                .collection('commentLikes')
                .doc(commentId)
                .collection('users')
                .doc(userId);
            const dislikeRef = admin.firestore()
                .collection('commentDislikes')
                .doc(commentId)
                .collection('users')
                .doc(userId);

            // Get current like/dislike state
            const likeDoc = await transaction.get(likeRef);
            const dislikeDoc = await transaction.get(dislikeRef);

            const isLiked = likeDoc.exists;
            const isDisliked = dislikeDoc.exists;

            // Determine update operations
            let likeChange = 0;
            let dislikeChange = 0;
            let pointChange = 0;

            // Handle like toggle
            if (isLiked) {
                // Unlike: remove like
                transaction.delete(likeRef);
                likeChange = -1;
                pointChange = -1;
            } else {
                // Like: add like
                transaction.set(likeRef, { timestamp: admin.firestore.FieldValue.serverTimestamp() });
                likeChange = 1;
                pointChange = 1;

                // If was disliked, remove dislike
                if (isDisliked) {
                    transaction.delete(dislikeRef);
                    dislikeChange = -1;
                    pointChange += 1;
                }
            }

            // Update comment like/dislike counts
            transaction.update(commentRef, {
                likeCount: admin.firestore.FieldValue.increment(likeChange),
                dislikeCount: admin.firestore.FieldValue.increment(dislikeChange)
            });

            // Update author's points (only if not toggling own comment)
            if (authorId !== userId && pointChange !== 0) {
                const authorRef = admin.firestore().collection('users').doc(authorId);
                transaction.update(authorRef, {
                    userPoints: admin.firestore.FieldValue.increment(pointChange)
                });
            }

            // Return the state for client sync
            return {
                isLiked: !isLiked,
                isDisliked: false,
                likeCount: (commentData.likeCount || 0) + likeChange,
                dislikeCount: (commentData.dislikeCount || 0) + dislikeChange,
                successful: true
            };
        });
    } catch (error) {
        console.error('Error handling comment like:', error);
        throw new HttpsError('internal', 'Failed to process comment like');
    }
});

/**
 * Cloud Function to handle comment dislikes
 */
exports.handleCommentDislike = onCall(async (request) => {
    const userId = request.auth.uid;
    const commentId = request.data.commentId;
    const postId = request.data.postId;
    const isAlt = request.data.isAlt || false;

    if (!commentId) {
        throw new HttpsError('invalid-argument', 'Comment ID is required');
    }

    try {
        return await admin.firestore().runTransaction(async (transaction) => {
            // Determine which collection to use based on privacy
            const postId = request.data.postId;
            if (!postId) {
                throw new HttpsError('invalid-argument', 'Post ID is required');
            }
            const commentRef = admin.firestore()
                .collection(isAlt ? 'altComments' : 'comments')
                .doc(postId)
                .collection('postComments')
                .doc(commentId);
            const commentDoc = await transaction.get(commentRef);
            if (!commentDoc.exists) {
                throw new HttpsError('not-found', 'Comment not found');
            }

            const commentData = commentDoc.data();
            const authorId = commentData.authorId;

            // References to like and dislike collections
            const likeRef = admin.firestore()
                .collection('commentLikes')
                .doc(commentId)
                .collection('users')
                .doc(userId);
            const dislikeRef = admin.firestore()
                .collection('commentDislikes')
                .doc(commentId)
                .collection('users')
                .doc(userId);

            // Get current like/dislike state
            const likeDoc = await transaction.get(likeRef);
            const dislikeDoc = await transaction.get(dislikeRef);

            const isLiked = likeDoc.exists;
            const isDisliked = dislikeDoc.exists;

            // Determine update operations
            let likeChange = 0;
            let dislikeChange = 0;
            let pointChange = 0;

            // Handle dislike toggle
            if (isDisliked) {
                // Undislike: remove dislike
                transaction.delete(dislikeRef);
                dislikeChange = -1;
                pointChange = 1;
            } else {
                // Dislike: add dislike
                transaction.set(dislikeRef, { timestamp: admin.firestore.FieldValue.serverTimestamp() });
                dislikeChange = 1;
                pointChange = -1;

                // If was liked, remove like
                if (isLiked) {
                    transaction.delete(likeRef);
                    likeChange = -1;
                    pointChange -= 1;
                }
            }

            // Update comment like/dislike counts
            transaction.update(commentRef, {
                likeCount: admin.firestore.FieldValue.increment(likeChange),
                dislikeCount: admin.firestore.FieldValue.increment(dislikeChange)
            });

            // Update author's points (only if not toggling own comment)
            if (authorId !== userId && pointChange !== 0) {
                const authorRef = admin.firestore().collection('users').doc(authorId);
                transaction.update(authorRef, {
                    userPoints: admin.firestore.FieldValue.increment(pointChange)
                });
            }

            // Return the state for client sync
            return {
                isLiked: false,
                isDisliked: !isDisliked,
                likeCount: (commentData.likeCount || 0) + likeChange,
                dislikeCount: (commentData.dislikeCount || 0) + dislikeChange,
                successful: true
            };
        });
    } catch (error) {
        console.error('Error handling comment dislike:', error);
        throw new HttpsError('internal', 'Failed to process comment dislike');
    }
});

// Hot algorithm implementation for post ranking
const hotAlgorithm = {
  /**
   * Calculate a hot score for a post based on votes and time
   * @param {number} netVotes - The net votes (likes - dislikes)
   * @param {Date} createdAt - When the post was created
   * @param {number} decayFactor - Controls how quickly posts decay (default: 1.0)
   * @returns {number} The calculated hot score
   */
  calculateHotScore: (netVotes, createdAt, decayFactor = 1.0) => {
    // Handle edge cases
    if (!createdAt) {
      createdAt = new Date();
    }

    // Calculate the sign and magnitude components
    const sign = Math.sign(netVotes);
    const magnitude = Math.log10(Math.max(1, Math.abs(netVotes)));

    // Calculate seconds since a reference date (epoch)
    const epochSeconds = Math.floor(createdAt.getTime() / 1000);
    const secondsOffset = epochSeconds - 1600000000; // Relative to a point in time

    // Apply decay factor - higher values make time more important
    const timeComponent = secondsOffset / (45000 * decayFactor);

    // Combine components into final score
    return sign * magnitude + timeComponent;
  },

  /**
   * Sort an array of posts using the hot algorithm
   * @param {Array} posts - Array of post objects
   * @param {number} decayFactor - How quickly posts decay with time
   * @returns {Array} Sorted posts array
   */
  sortByHotScore: (posts, decayFactor = 1.0) => {
    return [...posts].sort((a, b) => {
      const aScore = hotAlgorithm.calculateHotScore(
        a.likeCount - a.dislikeCount,
        a.createdAt ? a.createdAt.toDate() : new Date(),
        decayFactor
      );

      const bScore = hotAlgorithm.calculateHotScore(
        b.likeCount - b.dislikeCount,
        b.createdAt ? b.createdAt.toDate() : new Date(),
        decayFactor
      );

      return bScore - aScore; // Descending order
    });
  }
};

// Apply hot algorithm to public feed
exports.getPublicFeedPosts = functions.https.onCall(async (data, context) => {
  try {
    // Check authentication if needed
    if (!context.auth && requireAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'You must be logged in to access the public feed.'
      );
    }

    const userId = data.userId;
    const limit = data.limit || 20;
    const lastPostId = data.lastPostId || null;
    const decayFactor = data.decayFactor || 1.0;

    // Get feed posts from Firestore
    let feedQuery = db.collection('feeds')
      .doc(userId)
      .collection('userFeed')
      .orderBy('createdAt', 'desc')
      .limit(limit * 2); // Get more posts to allow for sorting

    // Apply pagination if provided
    if (lastPostId) {
      const lastPostDoc = await db.collection('posts').doc(lastPostId).get();
      if (lastPostDoc.exists) {
        feedQuery = feedQuery.startAfter(lastPostDoc);
      }
    }

    const feedSnapshot = await feedQuery.get();
    let feedPosts = [];

    // If user has a personalized feed, use it
    if (!feedSnapshot.empty) {
      feedPosts = feedSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));
    } else {
      // Otherwise get general public posts
      let postsQuery = db.collection('posts')
        .where('isAlt', '==', false)
        .orderBy('createdAt', 'desc')
        .limit(limit * 2);

      if (lastPostId) {
        const lastPostDoc = await db.collection('posts').doc(lastPostId).get();
        if (lastPostDoc.exists) {
          postsQuery = postsQuery.startAfter(lastPostDoc);
        }
      }

      const postsSnapshot = await postsQuery.get();
      feedPosts = postsSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));
    }

    // Apply hot algorithm to sort posts
    const sortedPosts = hotAlgorithm.sortByHotScore(feedPosts, decayFactor);

    // Return limited number of posts
    return { posts: sortedPosts.slice(0, limit) };
  } catch (error) {
    console.error('Error getting public feed:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});

// Apply hot algorithm to alt feed
exports.getAltFeedPosts = functions.https.onCall(async (data, context) => {
  try {
    // Check authentication
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'You must be logged in to access the alt feed.'
      );
    }

    const limit = data.limit || 15;
    const lastPostId = data.lastPostId || null;
    const decayFactor = data.decayFactor || 1.0;

    // Query globalAltPosts collection
    let postsQuery = db.collection('globalAltPosts')
      .orderBy('createdAt', 'desc')
      .limit(limit * 2); // Get more to allow for sorting

    if (lastPostId && data.lastCreatedAt) {
      // Use timestamp for pagination with orderBy
      const lastTimestamp = new admin.firestore.Timestamp(
        data.lastCreatedAt._seconds,
        data.lastCreatedAt._nanoseconds
      );
      postsQuery = postsQuery.startAfter(lastTimestamp);
    }

    const postsSnapshot = await postsQuery.get();
    const altPosts = postsSnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));

    // Apply hot algorithm to sort posts
    const sortedPosts = hotAlgorithm.sortByHotScore(altPosts, decayFactor);

    // Return limited number of posts
    return { posts: sortedPosts.slice(0, limit) };
  } catch (error) {
    console.error('Error getting alt feed:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});

// Get trending posts for public feed
exports.getTrendingPosts = functions.https.onCall(async (data, context) => {
  try {
    const limit = data.limit || 10;

    // Get recent posts with high engagement (last 24 hours)
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);

    const postsSnapshot = await db.collection('posts')
      .where('isAlt', '==', false)
      .where('createdAt', '>', yesterday)
      .orderBy('createdAt', 'desc')
      .limit(limit * 3) // Get more posts to allow for sorting
      .get();

    const posts = postsSnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));

    // Apply hot algorithm with more aggressive decay factor
    const trendingPosts = hotAlgorithm.sortByHotScore(posts, 0.5);

    return { posts: trendingPosts.slice(0, limit) };
  } catch (error) {
    console.error('Error getting trending posts:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});