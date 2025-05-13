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
    "every 5 minutes", // Change to "every 1 minutes" for testing
    async (event) => {
        // Only process posts from the last 7 days
        const oneWeekAgo = new Date();
        oneWeekAgo.setDate(oneWeekAgo.getDate() - 7);

        try {
            // Process regular posts
            await updatePostTypeHotScores('posts', null, oneWeekAgo);
            logger.info('Hot score update completed for regular posts');

            // Process alt posts
            await updatePostTypeHotScores('altPosts', null, oneWeekAgo);
            logger.info('Hot score update completed for alt posts');

            // Process herd posts - requires additional logic for nested collection
            const herdsSnapshot = await firestore.collection('herdPosts').get();

            logger.info(`Found ${herdsSnapshot.size} herds for hot score update`);

            for (const herdDoc of herdsSnapshot.docs) {
                const herdId = herdDoc.id;
                await updatePostTypeHotScores('herdPosts', herdId, oneWeekAgo);
                logger.info(`Hot score update completed for herd ${herdId}`);
            }

            logger.info('Hot score update completed successfully for all post types');
            return null;
        } catch (error) {
            logger.error('Error updating hot scores:', error);
            throw error;
        }
    }
);

/**
 * Helper function to update hot scores for a specific post type
 * @param {string} collectionName - The collection to update ('posts', 'altPosts')
 * @param {string|null} herdId - For herd posts, the ID of the herd
 * @param {Date} cutoffDate - Only process posts newer than this date
 */
async function updatePostTypeHotScores(collectionName, herdId, cutoffDate) {
    // Build the correct collection reference based on post type
    let collectionRef;
    if (collectionName === 'herdPosts' && herdId) {
        collectionRef = firestore.collection('herdPosts').doc(herdId).collection('posts');
    } else {
        collectionRef = firestore.collection(collectionName);
    }

    // Query for posts with significant engagement
    const postsQuery = collectionRef
        .where('createdAt', '>', cutoffDate)
        .where('likeCount', '>', 0)
        .orderBy('createdAt', 'asc')
        .orderBy('likeCount', 'asc')
        .limit(500);

    const postsSnapshot = await postsQuery.get();

    if (postsSnapshot.empty) {
        logger.info(`No ${collectionName}${herdId ? ' for herd ' + herdId : ''} found for hot score update`);
        return;
    }

    logger.info(`Updating hot scores for ${postsSnapshot.size} ${collectionName}${herdId ? ' in herd ' + herdId : ''}`);

    // Process in smaller batches to avoid Firestore limits
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

        // If batch is full, commit and reset
        if (operationCount >= MAX_BATCH_SIZE) {
            await batch.commit();

            // Update user feeds for this batch
            await updateUserFeedsForPosts(updatedPosts);

            batch = firestore.batch();
            operationCount = 0;
            updatedPosts = [];
        }
    }

    // Commit any remaining operations
    if (operationCount > 0) {
        await batch.commit();
        await updateUserFeedsForPosts(updatedPosts);
    }

    logger.info(`Hot score update completed for ${collectionName}${herdId ? ' in herd ' + herdId : ''}`);
}
