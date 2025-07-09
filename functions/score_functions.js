const { onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { logger } = require("firebase-functions");
const { admin, firestore } = require('./admin_init');
const { hotAlgorithm } = require('./utils');

/**
 * Scheduled job to update hot scores for all post types
 * Runs every hour to keep scores current (set to 1 minute for testing)
 */
exports.updateHotScores = onSchedule(
    "every 30 minutes",
    async (event) => {
        // Only process posts from the last 7 days
        const sevenDaysAgo = new Date();
        sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

        try {
            // First, set all posts older than 7 days to hot score 0
            await zeroOutOldPosts('posts', sevenDaysAgo);
            await zeroOutOldPosts('altPosts', sevenDaysAgo);

            // Process regular posts (only those with non-zero scores)
            await updatePostTypeHotScores('posts', null, sevenDaysAgo);
            logger.info('Hot score update completed for regular posts');

            // Process alt posts (only those with non-zero scores)
            await updatePostTypeHotScores('altPosts', null, sevenDaysAgo);
            logger.info('Hot score update completed for alt posts');

            // Process herd posts
            const herdsSnapshot = await firestore.collection('herdPosts').get();
            for (const herdDoc of herdsSnapshot.docs) {
                const herdId = herdDoc.id;
                await updatePostTypeHotScores('herdPosts', herdId, sevenDaysAgo);
            }

            logger.info('Hot score update completed successfully for all post types');
            return null;
        } catch (error) {
            logger.error('Error updating hot scores:', error);
            throw error;
        }
    }
);

async function zeroOutOldPosts(collectionName, cutoffDate) {
    const oldPostsQuery = firestore.collection(collectionName)
        .where('createdAt', '<', cutoffDate)
        .where('hotScore', '>', 0)
        .limit(500);

    const snapshot = await oldPostsQuery.get();

    if (snapshot.empty) {
        logger.info(`No old posts to zero out in ${collectionName}`);
        return;
    }

    const batch = firestore.batch();
    const updatedPosts = [];

    snapshot.docs.forEach(doc => {
        batch.update(doc.ref, { hotScore: 0 });
        updatedPosts.push({
            id: doc.id,
            hotScore: 0,
            sourceCollection: collectionName
        });
    });

    await batch.commit();

    // Update user feeds for these zeroed posts
    await updateUserFeedsForPosts(updatedPosts);

    logger.info(`Zeroed out ${snapshot.size} old posts in ${collectionName}`);
}


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
 * Helper function to update hot scores for a specific post type
 * @param {string} collectionName - The collection to update ('posts', 'altPosts')
 * @param {string|null} herdId - For herd posts, the ID of the herd
 * @param {Date} cutoffDate - Only process posts newer than this date
 */
async function updatePostTypeHotScores(collectionName, herdId, cutoffDate) {
    let collectionRef;
    if (collectionName === 'herdPosts' && herdId) {
        collectionRef = firestore.collection('herdPosts').doc(herdId).collection('posts');
    } else {
        collectionRef = firestore.collection(collectionName);
    }

    // UPDATED: Only query posts with non-zero hot scores
    const postsQuery = collectionRef
        .where('createdAt', '>', cutoffDate)
        .where('hotScore', '>', 0) // Only process posts with non-zero scores
        .orderBy('createdAt', 'asc')
        .orderBy('hotScore', 'asc')
        .limit(500);

    const postsSnapshot = await postsQuery.get();

    if (postsSnapshot.empty) {
        logger.info(`No active posts found for hot score update in ${collectionName}`);
        return;
    }

    logger.info(`Updating hot scores for ${postsSnapshot.size} active posts in ${collectionName}`);

    const MAX_BATCH_SIZE = 200;
    let batch = firestore.batch();
    let operationCount = 0;
    let updatedPosts = [];

    for (const doc of postsSnapshot.docs) {
        const postData = doc.data();
        const netVotes = postData.likeCount - (postData.dislikeCount || 0);
        const postId = doc.id;

        const updatedHotScore = hotAlgorithm.calculateHotScore(
            netVotes,
            postData.createdAt.toDate()
        );

        // Only update if score has changed significantly
        if (!postData.hotScore || Math.abs(postData.hotScore - updatedHotScore) > 0.001) {
            batch.update(doc.ref, { hotScore: updatedHotScore });
            updatedPosts.push({
                id: postId,
                hotScore: updatedHotScore,
                sourceCollection: collectionName,
                herdId: herdId
            });
            operationCount++;
        }

        if (operationCount >= MAX_BATCH_SIZE) {
            await batch.commit();
            await updateUserFeedsForPosts(updatedPosts);
            batch = firestore.batch();
            operationCount = 0;
            updatedPosts = [];
        }
    }

    if (operationCount > 0) {
        await batch.commit();
        await updateUserFeedsForPosts(updatedPosts);
    }

    logger.info(`Hot score update completed for ${collectionName}`);
}

/**
 * Calculate trending scores for recent posts
 * Trending posts are those created within the last 2 days with good engagement
 */
exports.calculateTrendingScores = onSchedule(
    "every 15 minutes",
    async (event) => {
        const twoDaysAgo = new Date();
        twoDaysAgo.setDate(twoDaysAgo.getDate() - 2);

        try {
            // Update trending scores for posts
            await updateTrendingScores('posts', twoDaysAgo);
            logger.info('Trending score update completed for posts');

            // Update trending scores for alt posts
            await updateTrendingScores('altPosts', twoDaysAgo);
            logger.info('Trending score update completed for alt posts');

            // Update trending scores for herd posts
            const herdsSnapshot = await firestore.collection('herdPosts').get();
            for (const herdDoc of herdsSnapshot.docs) {
                await updateTrendingScores(`herdPosts/${herdDoc.id}/posts`, twoDaysAgo);
            }
            logger.info('Trending score update completed for herd posts');

            return null;
        } catch (error) {
            logger.error('Error updating trending scores:', error);
            throw error;
        }
    }
);

/**
 * Helper function to update trending scores for a collection
 */
async function updateTrendingScores(collectionPath, cutoffDate) {
    const postsQuery = firestore.collection(collectionPath)
        .where('createdAt', '>', cutoffDate)
        .where('hotScore', '>', 0)
        .limit(500);

    const snapshot = await postsQuery.get();

    if (snapshot.empty) {
        logger.info(`No trending posts found in ${collectionPath}`);
        return;
    }

    const batch = firestore.batch();
    let updateCount = 0;

    snapshot.docs.forEach(doc => {
        const data = doc.data();
        const netVotes = (data.likeCount || 0) - (data.dislikeCount || 0);
        const createdAt = data.createdAt;

        // Calculate trending score (same as hot score but only for recent posts)
        const trendingScore = hotAlgorithm.calculateHotScore(netVotes, createdAt, 1.2); // Slight boost for trending

        batch.update(doc.ref, {
            trendingScore: trendingScore,
            topScore: data.likeCount || 0 // Also update top score
        });
        updateCount++;
    });

    if (updateCount > 0) {
        await batch.commit();
        logger.info(`Updated trending scores for ${updateCount} posts in ${collectionPath}`);
    }
}