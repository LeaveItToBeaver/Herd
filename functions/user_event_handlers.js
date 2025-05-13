const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { logger } = require("firebase-functions");
const { admin, firestore } = require('./admin_init');
const { hotAlgorithm, sanitizeData } = require('./utils');


/**
 * Update user feed when a follow/unfollow action occurs
 */
exports.handleFollowAction = onDocumentCreated(
    "followers/{followedId}/userFollowers/{followerId}",
    async (event) => {
        const followedId = event.params.followedId;
        const followerId = event.params.followerId;

        try {
            logger.info(`Follow action: ${followerId} is now following ${followedId}`);

            // Query all public posts from the followed user (not just recent ones)
            const postsQuery = firestore
                .collection('posts')
                .where('authorId', '==', followedId)
                .where('isAlt', '==', false) // Only public posts
                .orderBy('createdAt', 'desc')
                .limit(50); // Increased from 20 to get more historical posts

            const postsSnapshot = await postsQuery.get();

            if (postsSnapshot.empty) {
                logger.info(`No public posts found for user ${followedId}`);
                return null;
            }

            logger.info(`Found ${postsSnapshot.size} posts from ${followedId} to add to ${followerId}'s feed`);

            // Batch add posts to follower's feed
            const batch = firestore.batch();

            for (const doc of postsSnapshot.docs) {
                const postData = doc.data();
                const postId = doc.id;

                // Calculate hotScore if it doesn't exist
                const hotScore = postData.hotScore || hotAlgorithm.calculateHotScore(
                    (postData.likeCount || 0) - (postData.dislikeCount || 0),
                    postData.createdAt.toDate()
                );

                // Create minimal version of post data for the feed
                const feedPostData = {
                    id: postId,
                    authorId: postData.authorId,
                    authorName: postData.authorName || null,
                    authorUsername: postData.authorUsername || null,
                    authorProfileImageURL: postData.authorProfileImageURL || null,
                    content: postData.content,
                    createdAt: postData.createdAt,
                    likeCount: postData.likeCount || 0,
                    dislikeCount: postData.dislikeCount || 0,
                    commentCount: postData.commentCount || 0,
                    feedType: 'public',
                    hotScore: hotScore,
                    mediaItems: postData.mediaItems || [],
                    sourceCollection: 'posts'
                };

                const feedRef = firestore
                    .collection('userFeeds')
                    .doc(followerId)
                    .collection('feed')
                    .doc(postId);

                batch.set(feedRef, feedPostData);
            }

            await batch.commit();
            logger.info(`Successfully added ${postsSnapshot.size} posts to feed of user ${followerId}`);
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

