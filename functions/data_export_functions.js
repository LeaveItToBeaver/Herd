const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { onDocumentWritten } = require("firebase-functions/v2/firestore");
const { logger } = require("firebase-functions");
const { admin, firestore } = require('./admin_init');

/**
 * Callable function for users to request their data export
 * This processes the export directly (synchronously) for reliability
 */
const requestDataExport = onCall({
    enforceAppCheck: false,
    timeoutSeconds: 300, // 5 minutes timeout for large exports
}, async (request) => {
    // Validate authentication
    if (!request.auth) {
        throw new HttpsError('unauthenticated', 'User must be logged in');
    }

    const userId = request.auth.uid;
    const userEmail = request.auth.token.email;

    if (!userEmail) {
        throw new HttpsError('failed-precondition', 'User must have a verified email address');
    }

    try {
        // Check if there's already a pending/processing request
        const existingRequest = await firestore
            .collection('dataExportRequests')
            .doc(userId)
            .get();

        if (existingRequest.exists) {
            const data = existingRequest.data();
            if (data.status === 'pending' || data.status === 'processing') {
                return {
                    success: false,
                    message: 'You already have a pending data export request. Please wait for it to complete.',
                    status: data.status,
                    requestedAt: data.requestedAt?.toDate?.()?.toISOString() || null
                };
            }
        }

        // Create/update the data export request with 'processing' status
        await firestore.collection('dataExportRequests').doc(userId).set({
            userId: userId,
            email: userEmail,
            requestedAt: admin.firestore.FieldValue.serverTimestamp(),
            status: 'processing',
            exportType: 'full_account_data',
            processingStartedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        logger.info(`Data export processing started for user ${userId} to email ${userEmail}`);

        // Process the export directly (synchronously)
        try {
            // Collect all user data
            const exportData = await collectUserData(userId);

            // Store the export data
            const exportDocRef = await firestore.collection('dataExports').add({
                userId: userId,
                email: userEmail,
                exportedAt: admin.firestore.FieldValue.serverTimestamp(),
                data: exportData,
                expiresAt: admin.firestore.Timestamp.fromDate(
                    new Date(Date.now() + 7 * 24 * 60 * 60 * 1000) // 7 days from now
                ),
            });

            // Update the request status to completed
            await firestore.collection('dataExportRequests').doc(userId).update({
                status: 'completed',
                completedAt: admin.firestore.FieldValue.serverTimestamp(),
                exportDocId: exportDocRef.id,
            });

            // Send notification to admin
            await firestore.collection('adminNotifications').add({
                type: 'data_export_request',
                userId: userId,
                userEmail: userEmail,
                exportDocId: exportDocRef.id,
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
                read: false,
                message: `User ${userEmail} (${userId}) has requested a data export. Export ID: ${exportDocRef.id}`,
            });

            // Create an in-app notification for the user
            await firestore.collection('notifications').add({
                recipientId: userId,
                type: 'data_export_ready',
                title: 'Your Data Export is Ready',
                body: 'Your requested data export has been completed. Please contact support to receive your data.',
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
                read: false,
                data: {
                    exportDocId: exportDocRef.id,
                },
            });

            logger.info(`Data export completed for user ${userId}, export doc: ${exportDocRef.id}`);

            return {
                success: true,
                message: 'Your data export has been completed! You will receive a notification with further instructions.',
                exportDocId: exportDocRef.id,
            };
        } catch (processingError) {
            logger.error(`Error processing data export for user ${userId}:`, processingError);

            // Update status to failed
            await firestore.collection('dataExportRequests').doc(userId).update({
                status: 'failed',
                failedAt: admin.firestore.FieldValue.serverTimestamp(),
                error: processingError.message,
            });

            throw new HttpsError('internal', 'Failed to process data export. Please try again later.');
        }
    } catch (error) {
        if (error instanceof HttpsError) {
            throw error;
        }
        logger.error('Error requesting data export:', error);
        throw new HttpsError('internal', 'Failed to submit data export request');
    }
});

/**
 * Backup trigger that processes data export requests if they're stuck in 'pending'
 * This handles edge cases where the callable function might have failed mid-way
 */
const processDataExportRequest = onDocumentWritten(
    "dataExportRequests/{userId}",
    async (event) => {
        const userId = event.params.userId;
        const afterData = event.data?.after?.data();

        // Only process if status is 'pending' (backup mechanism)
        if (!afterData || afterData.status !== 'pending') {
            return null;
        }

        // Check if this request has been pending for more than 1 minute
        // (to avoid processing requests that are being handled by the callable)
        const requestedAt = afterData.requestedAt?.toDate?.();
        if (requestedAt) {
            const ageMs = Date.now() - requestedAt.getTime();
            if (ageMs < 60000) { // Less than 1 minute old
                logger.info(`Skipping pending request for ${userId} - too recent (${ageMs}ms old)`);
                return null;
            }
        }

        logger.info(`Backup trigger: Processing stuck pending request for user ${userId}`);

        try {
            // Update status to processing
            await firestore.collection('dataExportRequests').doc(userId).update({
                status: 'processing',
                processingStartedAt: admin.firestore.FieldValue.serverTimestamp(),
            });

            // Collect all user data
            const exportData = await collectUserData(userId);

            // Store the export data
            const exportDocRef = await firestore.collection('dataExports').add({
                userId: userId,
                email: afterData.email,
                exportedAt: admin.firestore.FieldValue.serverTimestamp(),
                data: exportData,
                expiresAt: admin.firestore.Timestamp.fromDate(
                    new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)
                ),
            });

            // Update the request status
            await firestore.collection('dataExportRequests').doc(userId).update({
                status: 'completed',
                completedAt: admin.firestore.FieldValue.serverTimestamp(),
                exportDocId: exportDocRef.id,
            });

            // Send notifications
            await firestore.collection('adminNotifications').add({
                type: 'data_export_request',
                userId: userId,
                userEmail: afterData.email,
                exportDocId: exportDocRef.id,
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
                read: false,
                message: `User ${afterData.email} (${userId}) has requested a data export. Export ID: ${exportDocRef.id}`,
            });

            await firestore.collection('notifications').add({
                recipientId: userId,
                type: 'data_export_ready',
                title: 'Your Data Export is Ready',
                body: 'Your requested data export has been completed. Please contact support to receive your data.',
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
                read: false,
                data: {
                    exportDocId: exportDocRef.id,
                },
            });

            logger.info(`Backup trigger: Data export completed for user ${userId}`);
            return { success: true, exportDocId: exportDocRef.id };
        } catch (error) {
            logger.error(`Backup trigger: Error processing data export for user ${userId}:`, error);

            await firestore.collection('dataExportRequests').doc(userId).update({
                status: 'failed',
                failedAt: admin.firestore.FieldValue.serverTimestamp(),
                error: error.message,
            });

            return { success: false, error: error.message };
        }
    }
);

/**
 * Collect all user data from various collections
 */
async function collectUserData(userId) {
    const exportData = {
        exportedAt: new Date().toISOString(),
        userId: userId,
    };

    try {
        // 1. User profile data
        const userDoc = await firestore.collection('users').doc(userId).get();
        if (userDoc.exists) {
            const userData = userDoc.data();
            // Remove sensitive fields that shouldn't be exported
            delete userData.fcmToken;
            delete userData.fcmTokenUpdatedAt;
            exportData.profile = userData;
        }

        // 2. Public posts
        const publicPostsSnapshot = await firestore
            .collection('posts')
            .where('authorId', '==', userId)
            .get();
        exportData.publicPosts = publicPostsSnapshot.docs.map(doc => ({
            id: doc.id,
            ...sanitizePostData(doc.data())
        }));

        // 3. Alt posts
        const altPostsSnapshot = await firestore
            .collection('altPosts')
            .where('authorId', '==', userId)
            .get();
        exportData.altPosts = altPostsSnapshot.docs.map(doc => ({
            id: doc.id,
            ...sanitizePostData(doc.data())
        }));

        // 4. Comments
        const commentsSnapshot = await firestore
            .collection('comments')
            .where('authorId', '==', userId)
            .get();
        exportData.comments = commentsSnapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data()
        }));

        // 5. Following list
        const followingSnapshot = await firestore
            .collection('following')
            .doc(userId)
            .collection('userFollowing')
            .get();
        exportData.following = followingSnapshot.docs.map(doc => ({
            userId: doc.id,
            ...doc.data()
        }));

        // 6. Followers list
        const followersSnapshot = await firestore
            .collection('followers')
            .doc(userId)
            .collection('userFollowers')
            .get();
        exportData.followers = followersSnapshot.docs.map(doc => ({
            userId: doc.id,
            ...doc.data()
        }));

        // 7. Alt connections
        const altConnectionsSnapshot = await firestore
            .collection('altConnections')
            .doc(userId)
            .collection('userConnections')
            .get();
        exportData.altConnections = altConnectionsSnapshot.docs.map(doc => ({
            connectionId: doc.id,
            ...doc.data()
        }));

        // 8. Alt connection requests (sent and received)
        const sentRequestsSnapshot = await firestore
            .collection('altConnectionRequests')
            .where('senderId', '==', userId)
            .get();
        exportData.sentConnectionRequests = sentRequestsSnapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data()
        }));

        const receivedRequestsSnapshot = await firestore
            .collection('altConnectionRequests')
            .where('receiverId', '==', userId)
            .get();
        exportData.receivedConnectionRequests = receivedRequestsSnapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data()
        }));

        // 9. Saved posts
        const savedPostsSnapshot = await firestore
            .collection('savedPosts')
            .doc(userId)
            .collection('posts')
            .get();
        exportData.savedPosts = savedPostsSnapshot.docs.map(doc => ({
            postId: doc.id,
            ...doc.data()
        }));

        // 10. Notifications (recent)
        const notificationsSnapshot = await firestore
            .collection('notifications')
            .where('recipientId', '==', userId)
            .orderBy('createdAt', 'desc')
            .limit(500)
            .get();
        exportData.notifications = notificationsSnapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data()
        }));

        // 11. Post interactions (likes/dislikes)
        const userInteractionsDoc = await firestore
            .collection('userInteractions')
            .doc(userId)
            .get();
        if (userInteractionsDoc.exists) {
            exportData.postInteractions = userInteractionsDoc.data();
        }

        // 12. Herd memberships
        const herdMembershipsSnapshot = await firestore
            .collectionGroup('members')
            .where('userId', '==', userId)
            .get();
        exportData.herdMemberships = herdMembershipsSnapshot.docs.map(doc => ({
            herdId: doc.ref.parent.parent?.id,
            ...doc.data()
        }));

        // 13. Chat messages (if any)
        // Note: This is a simplified version - chat messages might be in different collections
        try {
            const chatRoomsSnapshot = await firestore
                .collection('chatRooms')
                .where('participants', 'array-contains', userId)
                .get();

            exportData.chatRooms = [];
            for (const roomDoc of chatRoomsSnapshot.docs) {
                const messagesSnapshot = await firestore
                    .collection('chatRooms')
                    .doc(roomDoc.id)
                    .collection('messages')
                    .where('senderId', '==', userId)
                    .orderBy('timestamp', 'desc')
                    .limit(1000)
                    .get();

                exportData.chatRooms.push({
                    roomId: roomDoc.id,
                    roomData: roomDoc.data(),
                    userMessages: messagesSnapshot.docs.map(doc => ({
                        id: doc.id,
                        ...doc.data()
                    }))
                });
            }
        } catch (chatError) {
            logger.warn('Could not export chat data:', chatError);
            exportData.chatRooms = [];
        }

        // Add metadata
        exportData.metadata = {
            totalPublicPosts: exportData.publicPosts?.length || 0,
            totalAltPosts: exportData.altPosts?.length || 0,
            totalComments: exportData.comments?.length || 0,
            totalFollowing: exportData.following?.length || 0,
            totalFollowers: exportData.followers?.length || 0,
            totalAltConnections: exportData.altConnections?.length || 0,
            totalSavedPosts: exportData.savedPosts?.length || 0,
            totalHerdMemberships: exportData.herdMemberships?.length || 0,
        };

        return exportData;
    } catch (error) {
        logger.error('Error collecting user data:', error);
        throw error;
    }
}

/**
 * Sanitize post data for export (remove internal fields)
 */
function sanitizePostData(postData) {
    const sanitized = { ...postData };
    // Remove any internal tracking fields if needed
    delete sanitized.hotScore; // Internal ranking field
    return sanitized;
}

/**
 * Get data export status for a user
 */
const getDataExportStatus = onCall({
    enforceAppCheck: false,
}, async (request) => {
    if (!request.auth) {
        throw new HttpsError('unauthenticated', 'User must be logged in');
    }

    const userId = request.auth.uid;

    try {
        const exportRequest = await firestore
            .collection('dataExportRequests')
            .doc(userId)
            .get();

        if (!exportRequest.exists) {
            return {
                hasRequest: false,
                status: null,
            };
        }

        const data = exportRequest.data();
        return {
            hasRequest: true,
            status: data.status,
            requestedAt: data.requestedAt?.toDate?.()?.toISOString() || null,
            completedAt: data.completedAt?.toDate?.()?.toISOString() || null,
            exportDocId: data.exportDocId || null,
        };
    } catch (error) {
        logger.error('Error getting data export status:', error);
        throw new HttpsError('internal', 'Failed to get data export status');
    }
});

/**
 * Reset a stuck data export request (allows user to request again)
 * This can be called if a previous request got stuck
 */
const resetDataExportRequest = onCall({
    enforceAppCheck: false,
}, async (request) => {
    if (!request.auth) {
        throw new HttpsError('unauthenticated', 'User must be logged in');
    }

    const userId = request.auth.uid;

    try {
        const exportRequest = await firestore
            .collection('dataExportRequests')
            .doc(userId)
            .get();

        if (!exportRequest.exists) {
            return {
                success: true,
                message: 'No existing request found.',
            };
        }

        const data = exportRequest.data();

        // Only allow reset if stuck in pending/processing for more than 10 minutes
        // or if it failed
        if (data.status === 'completed') {
            // Delete completed requests to allow new ones
            await firestore.collection('dataExportRequests').doc(userId).delete();
            return {
                success: true,
                message: 'Previous completed request cleared. You can now request a new export.',
            };
        }

        if (data.status === 'failed') {
            await firestore.collection('dataExportRequests').doc(userId).delete();
            return {
                success: true,
                message: 'Previous failed request cleared. You can now request a new export.',
            };
        }

        // For pending/processing, check age
        const requestedAt = data.requestedAt?.toDate?.();
        if (requestedAt) {
            const ageMs = Date.now() - requestedAt.getTime();
            const ageMinutes = ageMs / (1000 * 60);

            if (ageMinutes > 10) {
                // Stuck for more than 10 minutes, allow reset
                await firestore.collection('dataExportRequests').doc(userId).delete();
                logger.info(`Reset stuck data export request for user ${userId} (was ${ageMinutes.toFixed(1)} minutes old)`);
                return {
                    success: true,
                    message: 'Stuck request cleared. You can now request a new export.',
                };
            } else {
                return {
                    success: false,
                    message: `Your request is still being processed. Please wait a few more minutes. (Request is ${ageMinutes.toFixed(1)} minutes old)`,
                };
            }
        }

        // If we can't determine age, allow reset
        await firestore.collection('dataExportRequests').doc(userId).delete();
        return {
            success: true,
            message: 'Request cleared. You can now request a new export.',
        };
    } catch (error) {
        logger.error('Error resetting data export request:', error);
        throw new HttpsError('internal', 'Failed to reset data export request');
    }
});

module.exports = {
    requestDataExport,
    processDataExportRequest,
    getDataExportStatus,
    resetDataExportRequest,
};
