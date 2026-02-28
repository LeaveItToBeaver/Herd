const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { onDocumentWritten } = require("firebase-functions/v2/firestore");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { logger } = require("firebase-functions");
const { admin, firestore } = require('./admin_init');

const { v4: uuidv4 } = require('uuid');

const storage = admin.storage();
const bucket = storage.bucket();

/**
 * Upload export data as a JSON file to Firebase Storage.
 * Returns an object with { storagePath, downloadUrl }.
 *
 * Uses a Firebase download token embedded in file metadata so the URL
 * works without IAM signBlob permissions (unlike getSignedUrl).
 */
async function uploadExportToStorage(userId, exportData) {
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
    const filePath = `data_exports/${userId}/export_${timestamp}.json`;
    const file = bucket.file(filePath);

    const jsonString = JSON.stringify(exportData, null, 2);
    const downloadToken = uuidv4();

    await file.save(jsonString, {
        metadata: {
            contentType: 'application/json',
            metadata: {
                userId: userId,
                exportedAt: new Date().toISOString(),
                expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString(),
                firebaseStorageDownloadTokens: downloadToken,
            },
        },
    });

    // Build a Firebase Storage download URL using the token
    const bucketName = bucket.name;
    const encodedPath = encodeURIComponent(filePath);
    const downloadUrl = `https://firebasestorage.googleapis.com/v0/b/${bucketName}/o/${encodedPath}?alt=media&token=${downloadToken}`;

    logger.info(`Uploaded data export for user ${userId} to ${filePath} (${(jsonString.length / 1024).toFixed(1)} KB)`);
    return { storagePath: filePath, downloadUrl };
}

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

            // Upload JSON to Firebase Storage
            const uploadResult = await uploadExportToStorage(userId, exportData);
            const storagePath = uploadResult.storagePath;
            const downloadUrl = uploadResult.downloadUrl;

            // Calculate expiration date (30 days from now)
            const expiresAt = admin.firestore.Timestamp.fromDate(
                new Date(Date.now() + 30 * 24 * 60 * 60 * 1000)
            );

            // Store lightweight metadata in Firestore (not the data blob)
            const exportDocRef = await firestore.collection('dataExports').add({
                userId: userId,
                email: userEmail,
                exportedAt: admin.firestore.FieldValue.serverTimestamp(),
                storagePath: storagePath,
                downloadUrl: downloadUrl,
                expiresAt: expiresAt,
                downloaded: false,
                downloadedAt: null,
                fileSizeBytes: JSON.stringify(exportData).length,
            });

            // Update the request status to completed
            await firestore.collection('dataExportRequests').doc(userId).update({
                status: 'completed',
                completedAt: admin.firestore.FieldValue.serverTimestamp(),
                exportDocId: exportDocRef.id,
                storagePath: storagePath,
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
                body: 'Your data export is ready to download. Tap to open the download page.',
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
                read: false,
                data: {
                    exportDocId: exportDocRef.id,
                    route: '/settings/data-export',
                },
            });

            logger.info(`Data export completed for user ${userId}, export doc: ${exportDocRef.id}, storage: ${storagePath}`);

            return {
                success: true,
                message: 'Your data export is ready! Go to your settings to download it.',
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

            // Upload JSON to Firebase Storage
            const storagePath = await uploadExportToStorage(userId, exportData);

            // Calculate expiration date (30 days from now)
            const expiresAt = admin.firestore.Timestamp.fromDate(
                new Date(Date.now() + 30 * 24 * 60 * 60 * 1000)
            );

            // Store lightweight metadata in Firestore
            const exportDocRef = await firestore.collection('dataExports').add({
                userId: userId,
                email: afterData.email,
                exportedAt: admin.firestore.FieldValue.serverTimestamp(),
                storagePath: storagePath,
                expiresAt: expiresAt,
                downloaded: false,
                downloadedAt: null,
                fileSizeBytes: JSON.stringify(exportData).length,
            });

            // Update the request status
            await firestore.collection('dataExportRequests').doc(userId).update({
                status: 'completed',
                completedAt: admin.firestore.FieldValue.serverTimestamp(),
                exportDocId: exportDocRef.id,
                storagePath: storagePath,
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
                body: 'Your data export is ready to download. Tap to open the download page.',
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
                read: false,
                data: {
                    exportDocId: exportDocRef.id,
                    route: '/settings/data-export',
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
 * Each query is wrapped in try-catch to continue even if some fail
 */
async function collectUserData(userId) {
    const exportData = {
        exportedAt: new Date().toISOString(),
        userId: userId,
        errors: [], // Track any collection errors
    };

    // Helper to safely execute a query and log errors
    async function safeQuery(name, queryFn) {
        try {
            return await queryFn();
        } catch (error) {
            logger.warn(`Failed to collect ${name} for user ${userId}:`, error.message);
            exportData.errors.push({ collection: name, error: error.message });
            return null;
        }
    }

    // 1. User profile data
    const userDoc = await safeQuery('profile', async () => {
        const doc = await firestore.collection('users').doc(userId).get();
        if (doc.exists) {
            const userData = doc.data();
            // Remove sensitive fields that shouldn't be exported
            delete userData.fcmToken;
            delete userData.fcmTokenUpdatedAt;
            return userData;
        }
        return null;
    });
    exportData.profile = userDoc;

    // 2. Public posts
    const publicPosts = await safeQuery('publicPosts', async () => {
        const snapshot = await firestore
            .collection('posts')
            .where('authorId', '==', userId)
            .get();
        return snapshot.docs.map(doc => ({
            id: doc.id,
            ...sanitizePostData(doc.data())
        }));
    });
    exportData.publicPosts = publicPosts || [];

    // 3. Alt posts
    const altPosts = await safeQuery('altPosts', async () => {
        const snapshot = await firestore
            .collection('altPosts')
            .where('authorId', '==', userId)
            .get();
        return snapshot.docs.map(doc => ({
            id: doc.id,
            ...sanitizePostData(doc.data())
        }));
    });
    exportData.altPosts = altPosts || [];

    // 4. Comments
    const comments = await safeQuery('comments', async () => {
        const snapshot = await firestore
            .collection('comments')
            .where('authorId', '==', userId)
            .get();
        return snapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data()
        }));
    });
    exportData.comments = comments || [];

    // 5. Following list
    const following = await safeQuery('following', async () => {
        const snapshot = await firestore
            .collection('following')
            .doc(userId)
            .collection('userFollowing')
            .get();
        return snapshot.docs.map(doc => ({
            userId: doc.id,
            ...doc.data()
        }));
    });
    exportData.following = following || [];

    // 6. Followers list
    const followers = await safeQuery('followers', async () => {
        const snapshot = await firestore
            .collection('followers')
            .doc(userId)
            .collection('userFollowers')
            .get();
        return snapshot.docs.map(doc => ({
            userId: doc.id,
            ...doc.data()
        }));
    });
    exportData.followers = followers || [];

    // 7. Alt connections
    const altConnections = await safeQuery('altConnections', async () => {
        const snapshot = await firestore
            .collection('altConnections')
            .doc(userId)
            .collection('userConnections')
            .get();
        return snapshot.docs.map(doc => ({
            connectionId: doc.id,
            ...doc.data()
        }));
    });
    exportData.altConnections = altConnections || [];

    // 8. Alt connection requests (sent)
    const sentRequests = await safeQuery('sentConnectionRequests', async () => {
        const snapshot = await firestore
            .collection('altConnectionRequests')
            .where('senderId', '==', userId)
            .get();
        return snapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data()
        }));
    });
    exportData.sentConnectionRequests = sentRequests || [];

    // 8b. Alt connection requests (received)
    const receivedRequests = await safeQuery('receivedConnectionRequests', async () => {
        const snapshot = await firestore
            .collection('altConnectionRequests')
            .where('receiverId', '==', userId)
            .get();
        return snapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data()
        }));
    });
    exportData.receivedConnectionRequests = receivedRequests || [];

    // 9. Saved posts
    const savedPosts = await safeQuery('savedPosts', async () => {
        const snapshot = await firestore
            .collection('savedPosts')
            .doc(userId)
            .collection('posts')
            .get();
        return snapshot.docs.map(doc => ({
            postId: doc.id,
            ...doc.data()
        }));
    });
    exportData.savedPosts = savedPosts || [];

    // 10. Notifications (recent) - without ordering to avoid index requirement
    const notifications = await safeQuery('notifications', async () => {
        const snapshot = await firestore
            .collection('notifications')
            .where('recipientId', '==', userId)
            .limit(500)
            .get();
        return snapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data()
        }));
    });
    exportData.notifications = notifications || [];

    // 11. Post interactions (likes/dislikes)
    const postInteractions = await safeQuery('postInteractions', async () => {
        const doc = await firestore
            .collection('userInteractions')
            .doc(userId)
            .get();
        return doc.exists ? doc.data() : null;
    });
    exportData.postInteractions = postInteractions;

    // 12. Herd memberships - this requires a composite index
    const herdMemberships = await safeQuery('herdMemberships', async () => {
        const snapshot = await firestore
            .collectionGroup('members')
            .where('userId', '==', userId)
            .get();
        return snapshot.docs.map(doc => ({
            herdId: doc.ref.parent.parent?.id,
            ...doc.data()
        }));
    });
    exportData.herdMemberships = herdMemberships || [];

    // 13. Chat rooms and messages
    const chatRooms = await safeQuery('chatRooms', async () => {
        const chatRoomsSnapshot = await firestore
            .collection('chatRooms')
            .where('participants', 'array-contains', userId)
            .get();

        const rooms = [];
        for (const roomDoc of chatRoomsSnapshot.docs) {
            // Get messages without ordering to avoid index requirement
            const messagesSnapshot = await firestore
                .collection('chatRooms')
                .doc(roomDoc.id)
                .collection('messages')
                .where('senderId', '==', userId)
                .limit(1000)
                .get();

            rooms.push({
                roomId: roomDoc.id,
                roomData: roomDoc.data(),
                userMessages: messagesSnapshot.docs.map(doc => ({
                    id: doc.id,
                    ...doc.data()
                }))
            });
        }
        return rooms;
    });
    exportData.chatRooms = chatRooms || [];

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
        collectionErrors: exportData.errors.length,
    };

    // Log if there were any errors
    if (exportData.errors.length > 0) {
        logger.warn(`Data export for ${userId} completed with ${exportData.errors.length} collection errors:`, exportData.errors);
    }

    return exportData;
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
 * Get data export status for a user, including download URL if ready
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
        const result = {
            hasRequest: true,
            status: data.status,
            requestedAt: data.requestedAt?.toDate?.()?.toISOString() || null,
            completedAt: data.completedAt?.toDate?.()?.toISOString() || null,
            exportDocId: data.exportDocId || null,
        };

        // If completed, get download info from the dataExports doc
        if (data.status === 'completed' && data.exportDocId) {
            const exportDoc = await firestore
                .collection('dataExports')
                .doc(data.exportDocId)
                .get();

            if (exportDoc.exists) {
                const exportData = exportDoc.data();
                const expiresAt = exportData.expiresAt?.toDate?.();
                const isExpired = expiresAt && expiresAt < new Date();

                result.storagePath = exportData.storagePath || null;
                result.downloaded = exportData.downloaded || false;
                result.downloadedAt = exportData.downloadedAt?.toDate?.()?.toISOString() || null;
                result.fileSizeBytes = exportData.fileSizeBytes || null;
                result.expiresAt = expiresAt?.toISOString() || null;
                result.isExpired = isExpired;

                // Return the stored download URL if not expired
                if (!isExpired && exportData.downloadUrl) {
                    result.downloadUrl = exportData.downloadUrl;
                } else if (!isExpired && exportData.storagePath) {
                    // Fallback: get or create a download token on the file
                    try {
                        const file = bucket.file(exportData.storagePath);
                        const [metadata] = await file.getMetadata();
                        let token = metadata.metadata?.firebaseStorageDownloadTokens;

                        // If the file has no download token, generate one and set it
                        if (!token) {
                            token = uuidv4();
                            await file.setMetadata({
                                metadata: {
                                    firebaseStorageDownloadTokens: token,
                                },
                            });
                            logger.info(`Generated new download token for ${exportData.storagePath}`);
                        }

                        const bucketName = bucket.name;
                        const encodedPath = encodeURIComponent(exportData.storagePath);
                        const downloadUrl = `https://firebasestorage.googleapis.com/v0/b/${bucketName}/o/${encodedPath}?alt=media&token=${token}`;
                        result.downloadUrl = downloadUrl;

                        // Persist the URL so future calls don't need the fallback
                        await firestore.collection('dataExports').doc(data.exportDocId).update({
                            downloadUrl: downloadUrl,
                        });
                    } catch (urlError) {
                        logger.warn('Failed to build download URL:', urlError.message);
                        result.downloadUrl = null;
                    }
                }
            }
        }

        return result;
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

/**
 * Scheduled cleanup function that runs daily to delete expired data exports.
 * Removes exports that are past their 30-day expiration OR
 * exports that were downloaded more than 7 days ago.
 */
const cleanupExpiredDataExports = onSchedule({
    schedule: 'every 24 hours',
    timeZone: 'America/New_York',
    retryCount: 2,
}, async (event) => {
    const now = new Date();
    let deletedCount = 0;
    let errorCount = 0;

    try {
        // Find all expired exports
        const expiredSnapshot = await firestore
            .collection('dataExports')
            .where('expiresAt', '<', admin.firestore.Timestamp.fromDate(now))
            .get();

        // Also find exports downloaded more than 7 days ago
        const sevenDaysAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
        const downloadedSnapshot = await firestore
            .collection('dataExports')
            .where('downloaded', '==', true)
            .where('downloadedAt', '<', admin.firestore.Timestamp.fromDate(sevenDaysAgo))
            .get();

        // Combine unique docs
        const docsToDelete = new Map();
        for (const doc of expiredSnapshot.docs) {
            docsToDelete.set(doc.id, doc);
        }
        for (const doc of downloadedSnapshot.docs) {
            docsToDelete.set(doc.id, doc);
        }

        logger.info(`Found ${docsToDelete.size} data exports to clean up`);

        for (const [docId, doc] of docsToDelete) {
            try {
                const data = doc.data();

                // Delete the file from Storage
                if (data.storagePath) {
                    try {
                        const file = bucket.file(data.storagePath);
                        const [exists] = await file.exists();
                        if (exists) {
                            await file.delete();
                            logger.info(`Deleted storage file: ${data.storagePath}`);
                        }
                    } catch (storageError) {
                        logger.warn(`Failed to delete storage file ${data.storagePath}:`, storageError.message);
                    }
                }

                // Delete the Firestore metadata doc
                await firestore.collection('dataExports').doc(docId).delete();

                // Also clean up the request doc if it exists
                if (data.userId) {
                    const requestDoc = await firestore
                        .collection('dataExportRequests')
                        .doc(data.userId)
                        .get();

                    if (requestDoc.exists &&
                        requestDoc.data().exportDocId === docId) {
                        await firestore.collection('dataExportRequests').doc(data.userId).delete();
                    }
                }

                deletedCount++;
            } catch (err) {
                logger.error(`Error cleaning up export ${docId}:`, err.message);
                errorCount++;
            }
        }

        logger.info(`Cleanup complete. Deleted: ${deletedCount}, Errors: ${errorCount}`);
    } catch (error) {
        logger.error('Error in data export cleanup:', error);
    }
});

module.exports = {
    requestDataExport,
    processDataExportRequest,
    getDataExportStatus,
    resetDataExportRequest,
    cleanupExpiredDataExports,
};
