const { onCall } = require("firebase-functions/v2/https");
const { logger } = require("firebase-functions");
const { admin, firestore } = require('./admin_init');

/**
 * Process users in smaller batches to avoid timeouts.
 * This version uses the corrected, simpler logic.
 */
exports.recalculateUserPostCountsBatch = onCall(
    { cors: true, timeoutSeconds: 540 },
    async (request) => {
        const { batchSize = 50, startAfterUserId = null } = request.data;
        
        logger.info(`Starting batch recalculation with batchSize: ${batchSize}, startAfter: ${startAfterUserId}`);
        
        try {
            // Get users in batches
            let usersQuery = firestore.collection('users').orderBy(admin.firestore.FieldPath.documentId()).limit(batchSize);
            
            if (startAfterUserId) {
                const startAfterDoc = await firestore.collection('users').doc(startAfterUserId).get();
                if (startAfterDoc.exists) {
                    usersQuery = usersQuery.startAfter(startAfterDoc);
                }
            }
            
            const usersSnapshot = await usersQuery.get();
            
            if (usersSnapshot.empty) {
                return {
                    success: true,
                    processedCount: 0,
                    message: 'No more users to process'
                };
            }
            
            let batch = firestore.batch();
            let processedCount = 0;
            let lastUserId = null;
            
            for (const userDoc of usersSnapshot.docs) {
                const userId = userDoc.id;
                lastUserId = userId;
                
                try {
                    // 1. Count public posts (from the 'posts' collection)
                    const publicPosts = await firestore.collection('posts')
                        .where('authorId', '==', userId)
                        .select().get();
                    
                    // 2. Count all alt posts (from the 'altPosts' collection)
                    // This correctly includes posts that are also herd posts.
                    const altPosts = await firestore.collection('altPosts')
                        .where('authorId', '==', userId)
                        .select().get();

                    const totalPosts = publicPosts.size;
                    const altTotalPosts = altPosts.size; // <-- This is the corrected logic
                    
                    // Add update operation to the batch
                    batch.update(firestore.collection('users').doc(userId), {
                        totalPosts: totalPosts,
                        altTotalPosts: altTotalPosts,
                        updatedAt: admin.firestore.FieldValue.serverTimestamp()
                    });
                    
                    processedCount++;
                    logger.info(`User ${userId}: ${totalPosts} public posts, ${altTotalPosts} alt posts`);
                    
                } catch (userError) {
                    logger.error(`Error processing user ${userId}:`, userError);
                }
            }
            
            // Commit the batch of updates
            if (processedCount > 0) {
                await batch.commit();
            }
            
            const hasMore = usersSnapshot.size === batchSize;
            
            return {
                success: true,
                processedCount,
                lastUserId,
                hasMore,
                message: `Processed ${processedCount} users. ${hasMore ? 'More users remain.' : 'All users processed.'}`
            };
            
        } catch (error) {
            logger.error('Error in batch recalculation:', error);
            return {
                success: false,
                error: error.message
            };
        }
    }
);

/**
 * Debug function to recalculate post counts for a specific user
 */
exports.recalculateUserPostCounts = onCall(
    { cors: true },
    async (request) => {
        const { userId } = request.data;
        
        if (!userId) {
            throw new Error('userId is required');
        }

        logger.info(`Recalculating post counts for user: ${userId}`);

        try {
            // 1. Count public posts
            const publicPosts = await firestore.collection('posts')
                .where('authorId', '==', userId)
                .select().get();

            // 2. Count all alt posts
            const altPosts = await firestore.collection('altPosts')
                .where('authorId', '==', userId)
                .select().get();

            const totalPosts = publicPosts.size;
            const altTotalPosts = altPosts.size;

            // Update user document
            await firestore.collection('users').doc(userId).update({
                totalPosts: totalPosts,
                altTotalPosts: altTotalPosts,
                updatedAt: admin.firestore.FieldValue.serverTimestamp()
            });

            const result = {
                success: true,
                userId,
                totalPosts,
                altTotalPosts,
                message: `Updated user ${userId}: ${totalPosts} public posts, ${altTotalPosts} alt posts`
            };

            logger.info('User recalculation completed:', result);
            return result;

        } catch (error) {
            logger.error(`Error recalculating for user ${userId}:`, error);
            return {
                success: false,
                userId,
                error: error.message
            };
        }
    }
);