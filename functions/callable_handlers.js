const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { logger } = require("firebase-functions");
const { admin, firestore } = require('./admin_init');
const { hotAlgorithm, sanitizeData } = require('./utils');

/**
 * Handle post interactions (likes/dislikes) with the unified feed approach
 */
exports.handlePostInteraction = onCall({
    enforceAppCheck: false,
},
    async (request) => {
        const {
            postId,
            interactionType,
            feedType,
            herdId
        } = request.data;

        // Validate authentication
        if (!request.auth) {
            throw new HttpsError('unauthenticated', 'User must be logged in');
        }

        if (feedType === 'herd' && !herdId) {
            throw new HttpsError('invalid-argument', 'herdId is required for herd posts');
        }


        const userId = request.auth.uid;

        let postRef;

        // If it's a herd post, we need to first find out where the full data is stored
        if (feedType === 'herd') {
            // First get the reference data from herdPosts
            const herdPostRefDoc = await firestore
                .collection('herdPosts')
                .doc(herdId)
                .collection('posts')
                .doc(postId)
                .get();

            if (!herdPostRefDoc.exists) {
                throw new HttpsError('not-found', 'Post reference not found');
            }

            // Extract the source collection from the reference data
            const sourceCollection = herdPostRefDoc.data().sourceCollection || 'altPosts';

            // Set reference to the actual full post data
            postRef = firestore.collection(sourceCollection).doc(postId);
        }
        else if (feedType === 'public') {
            postRef = firestore.collection('posts').doc(postId);
        }
        else if (feedType === 'alt') {
            postRef = firestore.collection('altPosts').doc(postId);
        }
        else {
            throw new HttpsError('invalid-argument', 'Invalid feed type');
        }

        // Define interaction configurations here - make sure it's defined before use
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

        // Validate interaction type early
        const config = interactions[interactionType];
        if (!config) {
            throw new HttpsError('invalid-argument', 'Invalid interaction type');
        }

        return firestore.runTransaction(async (transaction) => {
            // Get all document references first before any writes
            const postDoc = await transaction.get(postRef);

            if (!postDoc.exists) {
                throw new HttpsError('not-found', 'Post not found');
            }

            const postData = postDoc.data();

            const interactionRef = firestore
                .collection(config.collection)
                .doc(postId)
                .collection('userInteractions')
                .doc(userId);

            // Check current interaction state
            const currentInteraction = await transaction.get(interactionRef);
            const isCurrentlyInteracted = currentInteraction.exists;

            // Check if opposite interaction exists - do this read before any writes
            const oppositeCollection = interactionType === 'like' ? 'dislikes' : 'likes';
            const oppositeRef = firestore
                .collection(oppositeCollection)
                .doc(postId)
                .collection('userInteractions')
                .doc(userId);

            const oppositeInteraction = await transaction.get(oppositeRef);
            const hasOppositeInteraction = oppositeInteraction.exists;

            // NOW DO ALL WRITES AFTER ALL READS

            // Calculate the changes based on current state
            let likeChange = 0;
            let dislikeChange = 0;

            if (interactionType === 'like') {
                likeChange = isCurrentlyInteracted ? -1 : 1;
                dislikeChange = hasOppositeInteraction ? -1 : 0;
            } else { // dislike
                dislikeChange = isCurrentlyInteracted ? -1 : 1;
                likeChange = hasOppositeInteraction ? -1 : 0;
            }

            // Update post counts
            transaction.update(postRef, {
                likeCount: admin.firestore.FieldValue.increment(likeChange),
                dislikeCount: admin.firestore.FieldValue.increment(dislikeChange)
            });

            // Toggle user's interaction
            if (isCurrentlyInteracted) {
                transaction.delete(interactionRef);
            } else {
                transaction.set(interactionRef, {
                    timestamp: admin.firestore.FieldValue.serverTimestamp()
                });
            }

            // Remove opposite interaction if it exists
            if (hasOppositeInteraction) {
                transaction.delete(oppositeRef);
            }

            // Calculate updated hot score with new values
            const updatedLikeCount = postData.likeCount + likeChange;
            const updatedDislikeCount = postData.dislikeCount + dislikeChange;
            const netVotes = updatedLikeCount - updatedDislikeCount;
            const updatedHotScore = hotAlgorithm.calculateHotScore(
                netVotes,
                postData.createdAt.toDate()
            );

            logger.info(`Updated hot score for post ${postId}: ${updatedHotScore}`);

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
        feedType = 'public',
        herdId = null,
        limit = 15,
        lastHotScore = null,
        lastPostId = null
    } = request.data;

    // Validate required userId
    const userId = request.data.userId;

    // Add detailed logging
    logger.info(`getFeed called with params: ${JSON.stringify({
        userId, feedType, herdId, limit, lastHotScore, lastPostId
    })}`);

    if (!userId) {
        logger.error('getFeed called without userId');
        throw new HttpsError('invalid-argument', 'User ID is required');
    }

    try {
        // Different query strategy based on feed type
        let postsResult = {};

        if (feedType === 'public') {
            logger.info(`Getting public feed for user: ${userId}`);
            postsResult = await getPublicFeed(userId, limit, lastHotScore, lastPostId);
            logger.info(`hasMorePosts: ${postsResult.hasMorePosts}`);
        }
        else if (feedType === 'alt') {
            logger.info(`Getting alt feed, lastHotScore: ${lastHotScore}, lastPostId: ${lastPostId}, for user: ${userId}`);
            postsResult = await getAltFeed(limit, lastHotScore, lastPostId);
            logger.info(`hasMorePosts: ${postsResult.hasMorePosts}`);
        }
        else if (herdId) {
            logger.info(`Getting herd feed for herd: ${herdId}`);
            postsResult = await getHerdFeed(herdId, limit, lastHotScore, lastPostId);
            logger.info(`hasMorePosts: ${postsResult.hasMorePosts}`);
        } else {
            logger.info(`Defaulting to public feed for user: ${userId}`);
            postsResult = await getPublicFeed(userId, limit, lastHotScore, lastPostId);
            logger.info(`hasMorePosts: ${postsResult.hasMorePosts}`);
        }

        logger.info(`Feed query returned ${postsResult.posts?.length || 0} posts`);

        // Log the first post to verify structure
        if (postsResult.posts && postsResult.posts.length > 0) {
            logger.info(`Sample post: ${JSON.stringify({
                id: postsResult.posts[0].id,
                hotScore: postsResult.posts[0].hotScore,
                feedType: postsResult.posts[0].feedType
            })}`);
        }

        // Deep sanitize the entire response to remove any NaN values
        const sanitizedResult = sanitizeData({
            posts: postsResult.posts,
            lastHotScore: postsResult.lastHotScore,
            lastPostId: postsResult.lastPostId,
            hasMorePosts: postsResult.hasMorePosts
        });

        return sanitizedResult;
    } catch (error) {
        logger.error(`Error getting feed for user ${userId}:`, error);
        throw new HttpsError('internal', `Failed to get feed: ${error.message}`);
    }
});

// Add this function to your index.js file
exports.retroactivelyFillUserFeeds = onCall({
    enforceAppCheck: false,
    timeoutSeconds: 540, // 9 minutes, close to the max timeout
}, async (request) => {
    // Admin-only check (you should implement proper admin verification)
    if (!request.auth) {
        throw new HttpsError('unauthenticated', 'Authentication required');
    }

    const callerUid = request.auth.uid;

    // Verify admin status (implement this based on your admin structure)
    const adminDoc = await firestore.collection('admins').doc(callerUid).get();
    if (!adminDoc.exists) {
        throw new HttpsError('permission-denied', 'Admin access required');
    }

    const { batchSize = 50, startAfterUid = null } = request.data;

    try {
        // Setup query to get users in batches
        let usersQuery = firestore.collection('users');

        // Optional pagination
        if (startAfterUid) {
            const startAfterDoc = await firestore.collection('users').doc(startAfterUid).get();
            if (startAfterDoc.exists) {
                usersQuery = usersQuery.startAfter(startAfterDoc);
            }
        }

        // Get batch of users
        const usersSnapshot = await usersQuery.limit(batchSize).get();

        if (usersSnapshot.empty) {
            return {
                success: true,
                message: 'No users found to process',
                processedCount: 0,
                lastProcessedUid: null,
                complete: true
            };
        }

        logger.info(`Processing ${usersSnapshot.size} users for feed backfill`);

        let processedCount = 0;
        let lastProcessedUid = null;

        // Process each user
        for (const userDoc of usersSnapshot.docs) {
            const userId = userDoc.id;
            lastProcessedUid = userId;

            // Get users this person is following
            const followingSnapshot = await firestore
                .collection('following')
                .doc(userId)
                .collection('userFollowing')
                .get();

            if (followingSnapshot.empty) {
                logger.info(`User ${userId} is not following anyone, skipping`);
                processedCount++;
                continue;
            }

            // Get existing feed entries to avoid duplicates
            const existingFeedSnapshot = await firestore
                .collection('userFeeds')
                .doc(userId)
                .collection('feed')
                .get();

            // Create a Set of existing post IDs for fast lookup
            const existingPostIds = new Set();
            existingFeedSnapshot.forEach(doc => existingPostIds.add(doc.id));

            // Process each followed user
            for (const followingDoc of followingSnapshot.docs) {
                const followedUserId = followingDoc.id;

                // Get posts from followed user that aren't already in the feed
                const postsSnapshot = await firestore
                    .collection('posts')
                    .where('authorId', '==', followedUserId)
                    .where('isAlt', '==', false)
                    .orderBy('createdAt', 'desc')
                    .limit(100)
                    .get();

                if (postsSnapshot.empty) {
                    continue;
                }

                // Prepare batch write
                const batch = firestore.batch();
                let addedCount = 0;

                for (const postDoc of postsSnapshot.docs) {
                    const postId = postDoc.id;
                    const postData = postDoc.data();

                    // Skip if already in feed
                    if (existingPostIds.has(postId)) {
                        continue;
                    }

                    // Calculate hot score
                    const netVotes = (postData.likeCount || 0) - (postData.dislikeCount || 0);
                    const hotScore = hotAlgorithm.calculateHotScore(
                        netVotes,
                        postData.createdAt?.toDate() || new Date()
                    );

                    // Create feed entry
                    const feedRef = firestore
                        .collection('userFeeds')
                        .doc(userId)
                        .collection('feed')
                        .doc(postId);

                    batch.set(feedRef, {
                        id: postId,
                        authorId: postData.authorId,
                        authorName: postData.authorName || null,
                        authorUsername: postData.authorUsername || null,
                        authorProfileImageURL: postData.authorProfileImageURL || null,
                        content: postData.content || '',
                        createdAt: postData.createdAt,
                        feedType: 'public',
                        hotScore: hotScore,
                        likeCount: postData.likeCount || 0,
                        dislikeCount: postData.dislikeCount || 0,
                        commentCount: postData.commentCount || 0,
                        mediaItems: postData.mediaItems || [],
                        sourceCollection: 'posts'
                    });

                    addedCount++;
                    existingPostIds.add(postId); // Mark as processed

                    // Commit in batches of 500 (Firestore limit)
                    if (addedCount % 500 === 0) {
                        await batch.commit();
                        logger.info(`Committed batch of 500 posts for user ${userId}`);
                        batch = firestore.batch(); // Create a new batch
                    }
                }

                // Commit any remaining operations
                if (addedCount % 500 !== 0) {
                    await batch.commit();
                }

                logger.info(`Added ${addedCount} posts from ${followedUserId} to ${userId}'s feed`);
            }

            processedCount++;
            logger.info(`Completed processing user ${userId} (${processedCount} of ${usersSnapshot.size})`);
        }

        const isComplete = usersSnapshot.size < batchSize;

        return {
            success: true,
            processedCount,
            lastProcessedUid,
            complete: isComplete,
            message: isComplete
                ? 'All users processed successfully'
                : 'Batch completed, more users remain'
        };

    } catch (error) {
        logger.error(`Error in retroactivelyFillUserFeeds:`, error);
        throw new HttpsError('internal', error.message);
    }
});

exports.fillUserFeedOnFollow = onCall({
    enforceAppCheck: true,
    timeoutSeconds: 120, // 2 minutes should be enough for single user
}, async (request) => {
    // Authentication check
    if (!request.auth) {
        throw new HttpsError('unauthenticated', 'Authentication required');
    }

    const userId = request.auth.uid;
    const { followedUserId } = request.data;

    if (!followedUserId) {
        throw new HttpsError('invalid-argument', 'followedUserId is required');
    }

    try {
        logger.info(`Filling ${userId}'s feed with posts from ${followedUserId}`);

        // Get existing feed entries to avoid duplicates
        const existingFeedSnapshot = await firestore
            .collection('userFeeds')
            .doc(userId)
            .collection('feed')
            .get();

        // Create a Set of existing post IDs for fast lookup
        const existingPostIds = new Set();
        existingFeedSnapshot.forEach(doc => existingPostIds.add(doc.id));

        // Get posts from followed user
        const postsSnapshot = await firestore
            .collection('posts')
            .where('authorId', '==', followedUserId)
            .where('isAlt', '==', false)
            .orderBy('createdAt', 'desc')
            .limit(100)
            .get();

        if (postsSnapshot.empty) {
            return { success: true, addedCount: 0, message: 'No posts to add' };
        }

        // Prepare batch write
        const batch = firestore.batch();
        let addedCount = 0;

        for (const postDoc of postsSnapshot.docs) {
            const postId = postDoc.id;
            const postData = postDoc.data();

            // Skip if already in feed
            if (existingPostIds.has(postId)) {
                continue;
            }

            // Calculate hot score
            const netVotes = (postData.likeCount || 0) - (postData.dislikeCount || 0);
            const hotScore = hotAlgorithm.calculateHotScore(
                netVotes,
                postData.createdAt?.toDate() || new Date()
            );

            // Create feed entry
            const feedRef = firestore
                .collection('userFeeds')
                .doc(userId)
                .collection('feed')
                .doc(postId);

            batch.set(feedRef, {
                id: postId,
                authorId: postData.authorId,
                authorName: postData.authorName || null,
                authorUsername: postData.authorUsername || null,
                authorProfileImageURL: postData.authorProfileImageURL || null,
                content: postData.content || '',
                createdAt: postData.createdAt,
                feedType: 'public',
                hotScore: hotScore,
                likeCount: postData.likeCount || 0,
                dislikeCount: postData.dislikeCount || 0,
                commentCount: postData.commentCount || 0,
                mediaItems: postData.mediaItems || [],
                sourceCollection: 'posts'
            });

            addedCount++;

            // Commit in batches of 500 (Firestore limit)
            if (addedCount % 500 === 0) {
                await batch.commit();
                logger.info(`Committed batch of 500 posts for user ${userId}`);
                batch = firestore.batch(); // Create a new batch
            }
        }

        // Commit any remaining operations
        if (addedCount % 500 !== 0) {
            await batch.commit();
        }

        logger.info(`Added ${addedCount} posts from ${followedUserId} to ${userId}'s feed`);

        return {
            success: true,
            addedCount,
            message: `Added ${addedCount} posts to feed`
        };
    } catch (error) {
        logger.error(`Error in fillUserFeedOnFollow:`, error);
        throw new HttpsError('internal', error.message);
    }
});

/**
 * Get trending posts for discovery
 */
exports.getTrendingPosts = onCall(async (request) => {
    const { limit = 10, postType = 'all' } = request.data;

    try {
        // Get posts from the last 3 days with high engagement
        const threeDaysAgo = new Date();
        threeDaysAgo.setDate(threeDaysAgo.getDate() - 3);

        let postsQuery = firestore.collection('posts')
            .where('createdAt', '>', threeDaysAgo)
            .orderBy('createdAt', 'desc');

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

        // Convert to array and ensure date objects are properly converted
        let posts = postsSnapshot.docs.map(doc => {
            const data = doc.data();

            // Important: Convert Firestore timestamp to Date
            let createdAt = data.createdAt;
            if (createdAt && typeof createdAt.toDate === 'function') {
                createdAt = createdAt.toDate();
            } else if (!(createdAt instanceof Date)) {
                createdAt = new Date(); // Default fallback
            }

            return {
                id: doc.id,
                ...data,
                createdAt: createdAt // Replace with properly converted date
            };
        });

        // Now sort using the properly converted dates
        posts = hotAlgorithm.sortPosts(posts, 0.5);

        // Return top posts
        return { posts: posts.slice(0, limit) };
    } catch (error) {
        logger.error('Error getting trending posts:', error);
        throw new HttpsError('internal', `Failed to get trending posts: ${error.message}`);
    }
});

// Debug function to find documents with NaN hotScores
exports.findNaNHotScores = onCall(async (request) => {
    if (!request.auth || !request.auth.token.admin) {
        throw new HttpsError('permission-denied', 'Admin only function');
    }

    try {
        const collections = ['posts', 'altPosts'];
        const problematicDocs = [];

        for (const collectionName of collections) {
            const snapshot = await firestore.collection(collectionName).get();

            snapshot.docs.forEach(doc => {
                const data = doc.data();
                if ('hotScore' in data && (isNaN(data.hotScore) || data.hotScore === undefined)) {
                    problematicDocs.push({
                        collection: collectionName,
                        id: doc.id,
                        hotScore: data.hotScore,
                        data: {
                            likeCount: data.likeCount,
                            dislikeCount: data.dislikeCount,
                            createdAt: data.createdAt ? 'valid date' : 'invalid date'
                        }
                    });
                }
            });
        }

        return { problematicDocs };
    } catch (error) {
        logger.error('Error finding NaN hotScores:', error);
        throw new HttpsError('internal', `Error: ${error.message}`);
    }
});

exports.catchAndLogExceptions = onCall(async (request) => {
    try {
        const {
            errorMessage,
            stackTrace,
            errorCode,
            userId,
            route,
            action,
            appInfo
        } = request.data;

        if (!errorMessage) {
            throw new HttpsError("invalid-argument", 'Error Message is required');
        }

        const errorDoc = {
            errorMessage,
            stackTrace: stackTrace || 'No stack trace provided',
            errorCode: errorCode || 'No error code provided',
            userId: userId || 'No userId provided',
            route: route || 'No route provided',
            action: action || 'No action provided',
            appInfo: appInfo || 'No appInfo provided',
            timeStamp: admin.firestore.FieldValue.serverTimestamp(),
            authContext: request.auth ? {
                uid: request.data.uid,
                email: request.auth.token.email,
                emailVerified: request.auth.token.email_verified,
            } : null,
        };

        logger.error(`App Exception: ${errorMessage}`, {
            stackTrace,
            errorCode,
            userId,
            route,
            action
        });

        const docRef = await firestore
            .collection("appExceptions")
            .add(errorDoc);

    } catch (error) {
        logger.error(`Error in exception logging function`, error);
        throw new HttpsError('internal', `failed to log exception ${error.message}`);
    }
});
