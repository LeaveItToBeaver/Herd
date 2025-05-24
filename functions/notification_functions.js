const functions = require('firebase-functions');
const { onDocumentCreated, onDocumentDeleted, onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { onCall } = require("firebase-functions/v2/https");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const logger = functions.logger;

/**
 * Factory function that creates and returns all notification functions
 * @param {object} admin - Initialized Firebase Admin SDK
 * @returns {object} Object containing all notification functions
 */
module.exports = function (admin) {
    const firestore = admin.firestore();

    /**
     * Helper function to remove undefined values from an object
     */
    function removeUndefinedValues(obj) {
        const cleaned = {};
        for (const [key, value] of Object.entries(obj)) {
            if (value !== undefined && value !== null) {
                cleaned[key] = value;
            }
        }
        return cleaned;
    }

    /**
     * Helper function to send push notification
     */
    async function sendPushNotification(userId, title, body, data) {
        try {
            logger.log(`🔔 Sending push notification to user ${userId}: ${title}`);

            // Get user's FCM token
            const userSnapshot = await firestore.collection('users').doc(userId).get();
            const userData = userSnapshot.data();

            if (!userData || !userData.fcmToken) {
                logger.log(`❌ No FCM token found for user ${userId}`);
                return;
            }

            // Get user's notification settings
            const settingsSnapshot = await firestore
                .collection('notificationSettings')
                .doc(userId)
                .get();

            const settings = settingsSnapshot.exists ? settingsSnapshot.data() : null;

            // Check if user has notifications enabled
            if (settings && !settings.pushNotificationsEnabled) {
                logger.log(`🔕 Push notifications disabled for user ${userId}`);
                return;
            }

            // Check if user has muted notifications
            if (settings && settings.mutedUntil && settings.mutedUntil.toDate() > new Date()) {
                logger.log(`🔇 Notifications muted for user ${userId} until ${settings.mutedUntil.toDate()}`);
                return;
            }

            // Check if specific notification type is enabled
            const notificationType = data.type;
            let typeEnabled = true;

            if (settings) {
                switch (notificationType) {
                    case 'follow':
                        typeEnabled = settings.followNotifications !== false;
                        break;
                    case 'newPost':
                        typeEnabled = settings.postNotifications !== false;
                        break;
                    case 'postLike':
                        typeEnabled = settings.likeNotifications !== false;
                        break;
                    case 'comment':
                    case 'commentReply':
                        typeEnabled = settings.commentNotifications !== false;
                        break;
                    case 'connectionRequest':
                    case 'connectionAccepted':
                        typeEnabled = settings.connectionNotifications !== false;
                        break;
                    case 'postMilestone':
                        typeEnabled = settings.milestoneNotifications !== false;
                        break;
                }
            }

            if (!typeEnabled) {
                logger.log(`🔕 ${notificationType} notifications disabled for user ${userId}`);
                return;
            }

            // Clean data to remove undefined values
            const cleanData = removeUndefinedValues({
                ...data,
                notificationId: data.notificationId || '',
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
            });

            // Create message
            const message = {
                token: userData.fcmToken,
                notification: {
                    title,
                    body,
                },
                data: cleanData,
                android: {
                    priority: 'high',
                    notification: {
                        channelId: 'high_importance_channel',
                        priority: 'high',
                        defaultSound: true,
                        defaultVibrateTimings: true,
                        icon: 'ic_notification',
                        color: '#FF6B35',
                    },
                },
                apns: {
                    payload: {
                        aps: {
                            sound: 'default',
                            badge: 1,
                            alert: {
                                title: title,
                                body: body,
                            },
                        },
                    },
                },
            };

            // Send message
            const response = await admin.messaging().send(message);
            logger.log(`✅ Successfully sent notification: ${response}`);
        } catch (error) {
            logger.error(`❌ Error sending notification: ${error}`);

            // If token is invalid, remove it from user document
            if (error.code === 'messaging/invalid-registration-token' ||
                error.code === 'messaging/registration-token-not-registered') {
                logger.log(`🔄 Removing invalid FCM token for user ${userId}`);
                await firestore.collection('users').doc(userId).update({
                    fcmToken: admin.firestore.FieldValue.delete()
                });
            }
        }
    }

    /**
     * Create a notification in Firestore and send push notification
     */
    async function createNotification(params) {
        const {
            recipientId,
            senderId,
            type,
            title,
            body,
            postId,
            commentId,
            isAlt = false,
            count
        } = params;

        try {
            logger.log(`📝 Creating notification: ${type} from ${senderId} to ${recipientId}`);

            // Don't create notifications for self-actions
            if (senderId === recipientId) {
                logger.log(`⚠️ Skipping self-notification for user ${senderId}`);
                return null;
            }

            // Get sender information
            const senderSnapshot = await firestore.collection('users').doc(senderId).get();
            const senderData = senderSnapshot.exists ? senderSnapshot.data() : null;

            // Create notification document
            const notificationRef = firestore.collection('notifications').doc();
            const notificationId = notificationRef.id;

            // Determine sender details based on public/alt event
            const senderName = isAlt && senderData?.username
                ? senderData.username
                : `${senderData?.firstName || ''} ${senderData?.lastName || ''}`.trim() || 'Someone';

            const senderProfileImage = isAlt
                ? senderData?.altProfileImageURL
                : senderData?.profileImageURL;

            // Build notification data object, only including defined values
            const notificationData = {
                id: notificationId,
                recipientId,
                senderId,
                type,
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
                isRead: false,
                title: title || generateTitle(type, senderName, count),
                body: body || generateBody(type, senderName, count),
                senderName: senderName,
                isAlt,
            };

            // Only add optional fields if they have values
            if (postId) {
                notificationData.postId = postId;
            }

            if (commentId) {
                notificationData.commentId = commentId;
            }

            if (senderData?.username) {
                notificationData.senderUsername = senderData.username;
            }

            if (senderProfileImage) {
                notificationData.senderProfileImage = senderProfileImage;
            }

            if (senderData?.altProfileImageURL) {
                notificationData.senderAltProfileImage = senderData.altProfileImageURL;
            }

            if (count !== undefined && count !== null) {
                notificationData.count = count;
            }

            // Save notification to Firestore
            await notificationRef.set(notificationData);
            logger.log(`✅ Notification saved to Firestore: ${notificationId}`);

            // Prepare push notification data (also clean undefined values)
            const pushData = removeUndefinedValues({
                type,
                senderId,
                postId: postId || '',
                commentId: commentId || '',
                isAlt: isAlt ? 'true' : 'false',
                notificationId
            });

            // Send push notification
            await sendPushNotification(
                recipientId,
                notificationData.title,
                notificationData.body,
                pushData
            );

            return notificationData;
        } catch (error) {
            logger.error(`❌ Error creating notification: ${error}`);
            throw error;
        }
    }

    /**
     * Generate notification title based on type
     */
    function generateTitle(type, senderName = 'Someone', count = null) {
        switch (type) {
            case 'follow':
                return 'New Follower';
            case 'newPost':
                return 'New Post';
            case 'postLike':
                return 'Post Liked';
            case 'comment':
                return 'New Comment';
            case 'commentReply':
                return 'New Reply';
            case 'connectionRequest':
                return 'Connection Request';
            case 'connectionAccepted':
                return 'Connection Accepted';
            case 'postMilestone':
                return `🎉 ${count} Likes!`;
            default:
                return 'New Notification';
        }
    }

    /**
     * Generate notification body based on type
     */
    function generateBody(type, senderName = 'Someone', count = null) {
        switch (type) {
            case 'follow':
                return `${senderName} started following you`;
            case 'newPost':
                return `${senderName} shared a new post`;
            case 'postLike':
                return `${senderName} liked your post`;
            case 'comment':
                return `${senderName} commented on your post`;
            case 'commentReply':
                return `${senderName} replied to your comment`;
            case 'connectionRequest':
                return `${senderName} wants to connect`;
            case 'connectionAccepted':
                return `${senderName} accepted your connection request`;
            case 'postMilestone':
                return `Your post reached ${count} likes!`;
            default:
                return 'You have a new notification';
        }
    }

    // Return an object with all the exported functions
    return {
        // When someone follows a user - FIXED
        onNewFollower: onDocumentCreated("following/{followerId}/userFollowing/{followedId}",
            async (event) => {
                const followerId = event.params.followerId;
                const followedId = event.params.followedId;

                logger.log(`👥 New follow: ${followerId} → ${followedId}`);

                await createNotification({
                    recipientId: followedId,
                    senderId: followerId,
                    type: 'follow',
                    // Don't pass undefined postId or commentId
                });
            }),

        // When someone creates a new post (notify followers) - FIXED
        onNewPost: onDocumentCreated("posts/{postId}", async (event) => {
            const postData = event.data.data();
            const authorId = postData.authorId;
            const postId = event.params.postId;

            // Skip alt posts
            if (postData.isAlt === true) {
                logger.log(`⏭️ Skipping alt post notification for ${postId}`);
                return;
            }

            logger.log(`📝 New post created: ${postId} by ${authorId}`);

            // Get followers
            const followersSnapshot = await firestore
                .collection('followers')
                .doc(authorId)
                .collection('userFollowers')
                .get();

            if (followersSnapshot.empty) {
                logger.log(`👥 No followers to notify for user ${authorId}`);
                return;
            }

            logger.log(`📤 Notifying ${followersSnapshot.size} followers`);

            // Create notifications for each follower (in batches to avoid timeout)
            const notificationPromises = [];

            for (const followerDoc of followersSnapshot.docs) {
                const followerId = followerDoc.id;

                // Create notification for this follower
                notificationPromises.push(
                    createNotification({
                        recipientId: followerId,
                        senderId: authorId,
                        type: 'newPost',
                        postId: postId, // This is defined
                        isAlt: false,
                    })
                );

                // Process in batches of 10 to avoid overwhelming the system
                if (notificationPromises.length >= 10) {
                    await Promise.all(notificationPromises);
                    notificationPromises.length = 0; // Clear array
                }
            }

            // Process remaining notifications
            if (notificationPromises.length > 0) {
                await Promise.all(notificationPromises);
            }

            logger.log(`✅ Post notifications sent for ${postId}`);
        }),

        // When someone likes a post - FIXED
        onPostLike: onDocumentCreated("likes/{postId}/userInteractions/{userId}",
            async (event) => {
                const postId = event.params.postId;
                const likerId = event.params.userId;

                logger.log(`❤️ Post liked: ${postId} by ${likerId}`);

                // Get post data - check both regular and alt posts
                let postSnapshot = await firestore.collection('posts').doc(postId).get();
                let isAlt = false;

                if (!postSnapshot.exists) {
                    postSnapshot = await firestore.collection('altPosts').doc(postId).get();
                    isAlt = true;
                }

                if (!postSnapshot.exists) {
                    logger.error(`❌ Post ${postId} not found for like notification`);
                    return;
                }

                const postData = postSnapshot.data();
                const authorId = postData.authorId;

                // Skip if user likes their own post
                if (likerId === authorId) {
                    logger.log(`⏭️ Skipping self-like for post ${postId}`);
                    return;
                }

                // Create like notification
                await createNotification({
                    recipientId: authorId,
                    senderId: likerId,
                    type: 'postLike',
                    postId: postId, // This is defined
                    isAlt,
                });

                // Check for milestone (10, 25, 50, 100, 500, 1000 likes)
                const currentLikeCount = postData.likeCount || 0;
                const milestones = [10, 25, 50, 100, 500, 1000];

                if (milestones.includes(currentLikeCount)) {
                    logger.log(`🎉 Milestone reached: ${currentLikeCount} likes for post ${postId}`);

                    await createNotification({
                        recipientId: authorId,
                        senderId: authorId, // System notification
                        type: 'postMilestone',
                        postId: postId, // This is defined
                        count: currentLikeCount, // This is defined
                        isAlt,
                    });
                }
            }),

        // When someone comments on a post - FIXED
        onNewComment: onDocumentCreated("comments/{postId}/postComments/{commentId}",
            async (event) => {
                const postId = event.params.postId;
                const commentId = event.params.commentId;
                const commentData = event.data.data();

                logger.log(`💬 New comment: ${commentId} on post ${postId}`);

                const commenterId = commentData.authorId;

                // Check if this is a reply to another comment
                if (commentData.parentId) {
                    // This is a reply to a comment
                    const parentCommentSnapshot = await firestore
                        .collection('comments')
                        .doc(postId)
                        .collection('postComments')
                        .doc(commentData.parentId)
                        .get();

                    if (parentCommentSnapshot.exists) {
                        const parentCommentData = parentCommentSnapshot.data();
                        const parentCommentAuthorId = parentCommentData.authorId;

                        // Skip if user replies to their own comment
                        if (commenterId !== parentCommentAuthorId) {
                            await createNotification({
                                recipientId: parentCommentAuthorId,
                                senderId: commenterId,
                                type: 'commentReply',
                                postId: postId, // This is defined
                                commentId: commentId, // This is defined
                                isAlt: commentData.isAltPost || false,
                            });
                        }
                    }
                } else {
                    // This is a direct comment on the post
                    // Get post data to find the author
                    let postSnapshot = await firestore.collection('posts').doc(postId).get();
                    let isAlt = false;

                    if (!postSnapshot.exists) {
                        postSnapshot = await firestore.collection('altPosts').doc(postId).get();
                        isAlt = true;
                    }

                    if (postSnapshot.exists) {
                        const postData = postSnapshot.data();
                        const postAuthorId = postData.authorId;

                        // Skip if user comments on their own post
                        if (commenterId !== postAuthorId) {
                            await createNotification({
                                recipientId: postAuthorId,
                                senderId: commenterId,
                                type: 'comment',
                                postId: postId, // This is defined
                                commentId: commentId, // This is defined
                                isAlt,
                            });
                        }
                    }
                }
            }),

        // When someone sends a connection request - FIXED
        onConnectionRequest: onDocumentCreated("altConnectionRequests/{userId}/requests/{requesterId}",
            async (event) => {
                const userId = event.params.userId;
                const requesterId = event.params.requesterId;

                logger.log(`🤝 Connection request: ${requesterId} → ${userId}`);

                await createNotification({
                    recipientId: userId,
                    senderId: requesterId,
                    type: 'connectionRequest',
                    isAlt: true,
                    // Don't pass undefined postId or commentId
                });
            }),

        // When someone accepts a connection request - FIXED
        onConnectionAccepted: onDocumentUpdated("altConnectionRequests/{userId}/requests/{requesterId}",
            async (event) => {
                const after = event.data.after.data();
                const before = event.data.before.data();

                // Only trigger when status changes from pending to accepted
                if (before.status === 'pending' && after.status === 'accepted') {
                    const userId = event.params.userId;
                    const requesterId = event.params.requesterId;

                    logger.log(`✅ Connection accepted: ${userId} accepted ${requesterId}`);

                    await createNotification({
                        recipientId: requesterId,
                        senderId: userId,
                        type: 'connectionAccepted',
                        isAlt: true,
                        // Don't pass undefined postId or commentId
                    });
                }
            }),

        // Cloud function to mark notifications as read
        markNotificationsAsRead: onCall(async (request) => {
            if (!request.auth) {
                throw new functions.https.HttpsError(
                    'unauthenticated',
                    'User must be logged in'
                );
            }

            const userId = request.auth.uid;
            const { notificationIds } = request.data;

            try {
                if (notificationIds && Array.isArray(notificationIds) && notificationIds.length > 0) {
                    // Mark specific notifications as read
                    const batch = firestore.batch();

                    for (const id of notificationIds) {
                        const notificationRef = firestore.collection('notifications').doc(id);
                        batch.update(notificationRef, {
                            isRead: true,
                            readAt: admin.firestore.FieldValue.serverTimestamp()
                        });
                    }

                    await batch.commit();
                    return { success: true, count: notificationIds.length };
                } else {
                    // Mark all notifications as read
                    const notificationsSnapshot = await firestore
                        .collection('notifications')
                        .where('recipientId', '==', userId)
                        .where('isRead', '==', false)
                        .get();

                    if (notificationsSnapshot.empty) {
                        return { success: true, count: 0 };
                    }

                    const batch = firestore.batch();
                    notificationsSnapshot.docs.forEach(doc => {
                        batch.update(doc.ref, {
                            isRead: true,
                            readAt: admin.firestore.FieldValue.serverTimestamp()
                        });
                    });

                    await batch.commit();
                    return { success: true, count: notificationsSnapshot.size };
                }
            } catch (error) {
                logger.error('❌ Error marking notifications as read:', error);
                throw new functions.https.HttpsError('internal', error.message);
            }
        }),

        // Cloud function to delete notifications
        deleteNotifications: onCall(async (request) => {
            if (!request.auth) {
                throw new functions.https.HttpsError(
                    'unauthenticated',
                    'User must be logged in'
                );
            }

            const userId = request.auth.uid;
            const { notificationIds } = request.data;

            try {
                if (!notificationIds || !Array.isArray(notificationIds)) {
                    throw new functions.https.HttpsError(
                        'invalid-argument',
                        'notificationIds must be an array'
                    );
                }

                const batch = firestore.batch();
                const verifiedIds = [];

                for (const id of notificationIds) {
                    const notificationRef = firestore.collection('notifications').doc(id);
                    const notificationDoc = await notificationRef.get();

                    if (notificationDoc.exists && notificationDoc.data().recipientId === userId) {
                        batch.delete(notificationRef);
                        verifiedIds.push(id);
                    }
                }

                if (verifiedIds.length === 0) {
                    return { success: true, count: 0 };
                }

                await batch.commit();
                return { success: true, count: verifiedIds.length };
            } catch (error) {
                logger.error('❌ Error deleting notifications:', error);
                throw new functions.https.HttpsError('internal', error.message);
            }
        }),

        // Clean up old notifications (run monthly) - V2 SYNTAX
        cleanupOldNotifications: onSchedule("0 0 1 * *", async (event) => {
            const thirtyDaysAgo = new Date();
            thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

            const oldNotificationsSnapshot = await firestore
                .collection('notifications')
                .where('timestamp', '<', thirtyDaysAgo)
                .get();

            if (oldNotificationsSnapshot.empty) {
                logger.log('🧹 No old notifications to clean up');
                return;
            }

            logger.log(`🧹 Cleaning up ${oldNotificationsSnapshot.size} old notifications`);

            const batch = firestore.batch();
            oldNotificationsSnapshot.docs.forEach(doc => {
                batch.delete(doc.ref);
            });

            await batch.commit();
            logger.log(`✅ Cleaned up ${oldNotificationsSnapshot.size} old notifications`);
        })
    };
};