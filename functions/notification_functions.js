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

    const debugFCMToken = onCall(async (request) => {
        if (!request.auth) {
            throw new functions.https.HttpsError('unauthenticated', 'User must be logged in');
        }

        const userId = request.auth.uid;

        try {
            // Get user document
            const userDoc = await firestore.collection('users').doc(userId).get();
            const userData = userDoc.data();

            console.log(`=== FCM DEBUG FOR USER ${userId} ===`);
            console.log('User exists:', userDoc.exists);
            console.log('FCM Token:', userData?.fcmToken ? `${userData.fcmToken.substring(0, 20)}...` : 'NO TOKEN');
            console.log('Token updated at:', userData?.fcmTokenUpdatedAt);

            if (userData?.fcmToken) {
                // Test sending a simple message
                const testMessage = {
                    token: userData.fcmToken,
                    notification: {
                        title: 'Test Notification',
                        body: 'This is a test from Firebase Cloud Functions'
                    },
                    android: {
                        priority: 'high',
                        notification: {
                            channelId: 'high_importance_channel',
                            priority: 'high',
                            defaultSound: true,
                            defaultVibrateTimings: true,
                        }
                    },
                    apns: {
                        headers: {
                            'apns-priority': '10',
                            'apns-push-type': 'alert',
                        },
                        payload: {
                            aps: {
                                alert: {
                                    title: 'Test Notification',
                                    body: 'This is a test from Firebase Cloud Functions'
                                },
                                sound: 'default',
                            }
                        }
                    }
                };

                try {
                    const response = await admin.messaging().send(testMessage);
                    console.log('Test message sent successfully:', response);

                    return {
                        success: true,
                        hasToken: true,
                        tokenPreview: userData.fcmToken.substring(0, 20),
                        messageSent: true,
                        messageId: response
                    };
                } catch (sendError) {
                    console.log('Error sending test message:', sendError);

                    return {
                        success: false,
                        hasToken: true,
                        tokenPreview: userData.fcmToken.substring(0, 20),
                        messageSent: false,
                        error: sendError.message,
                        errorCode: sendError.code
                    };
                }
            } else {
                return {
                    success: false,
                    hasToken: false,
                    message: 'No FCM token found for user'
                };
            }

        } catch (error) {
            console.log('Error in FCM debug:', error);
            throw new functions.https.HttpsError('internal', error.message);
        }
    });

    /**
     * Helper function to remove undefined values from an object
     */
    function removeUndefinedValues(obj) {
        const cleaned = {};
        for (const [key, value] of Object.entries(obj)) {
            if (value !== undefined && value !== null) {
                // Convert all values to strings for FCM data payload
                cleaned[key] = String(value);
            }
        }
        return cleaned;
    }

    /**
     * Enhanced push notification function with better error handling
     */
    async function sendPushNotification(userId, title, body, data) {
        try {
            logger.log(`Sending push notification to user ${userId}: ${title}`);

            // Get user's FCM token
            const userSnapshot = await firestore.collection('users').doc(userId).get();
            const userData = userSnapshot.data();

            if (!userData || !userData.fcmToken) {
                logger.log(`No FCM token found for user ${userId}`);
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
                    case 'chatMessage':
                        typeEnabled = settings.chatNotifications !== false;
                        break;
                }
            }

            if (!typeEnabled) {
                logger.log(`🔕 ${notificationType} notifications disabled for user ${userId}`);
                return;
            }

            // Clean data to remove undefined values and ensure all values are strings
            const cleanData = removeUndefinedValues({
                ...data,
                notificationId: data.notificationId || '',
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
            });

            // Create message with improved structure
            const message = {
                token: userData.fcmToken,
                notification: {
                    title: title,
                    body: body,
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
                        clickAction: 'FLUTTER_NOTIFICATION_CLICK',
                        tag: notificationType, // Helps group similar notifications
                    },
                    data: cleanData, // Android also needs data here for background handling
                },
                apns: {
                    headers: {
                        'apns-priority': '10',
                        'apns-push-type': 'alert',
                    },
                    payload: {
                        aps: {
                            alert: {
                                title: title,
                                body: body,
                            },
                            sound: 'default',
                            badge: await getUnreadCount(userId), // Set badge count
                            'content-available': 1, // For background processing
                            category: notificationType,
                        },
                        ...cleanData, // iOS custom data goes in the root payload
                    },
                },
                fcmOptions: {
                    analyticsLabel: `notification_${notificationType}`,
                },
            };

            // Send message
            const response = await admin.messaging().send(message);
            logger.log(` Successfully sent notification: ${response}`);

            // Log the message structure for debugging
            logger.log(`Message structure: ${JSON.stringify(message, null, 2)}`);

        } catch (error) {
            logger.error(`Error sending notification: ${error}`);
            logger.error(`Error details: ${JSON.stringify(error, null, 2)}`);

            // If token is invalid, remove it from user document
            if (error.code === 'messaging/invalid-registration-token' ||
                error.code === 'messaging/registration-token-not-registered') {
                logger.log(`Removing invalid FCM token for user ${userId}`);
                await firestore.collection('users').doc(userId).update({
                    fcmToken: admin.firestore.FieldValue.delete()
                });
            }
        }
    }

    /**
     * Get unread notification count for a user
     */
    async function getUnreadCount(userId) {
        try {
            const snapshot = await firestore
                .collection('notifications')
                .doc(userId)
                .collection('userNotifications')
                .where('isRead', '==', false)
                .select() // Only get document metadata, not full data
                .get();

            return snapshot.size;
        } catch (error) {
            logger.error(`Error getting unread count for ${userId}:`, error);
            return 0;
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
            chatId,
            messageId,
            isAlt = false,
            count
        } = params;

        try {
            logger.log(`📝 Creating notification: ${type} from ${senderId} to ${recipientId}`);

            // Don't create notifications for self-actions
            if (senderId === recipientId) {
                logger.log(`Skipping self-notification for user ${senderId}`);
                return null;
            }

            // Get sender information
            const senderSnapshot = await firestore.collection('users').doc(senderId).get();
            const senderData = senderSnapshot.exists ? senderSnapshot.data() : null;

            // Create notification document in user's subcollection
            const notificationRef = firestore
                .collection('notifications')
                .doc(recipientId)
                .collection('userNotifications')
                .doc();
            const notificationId = notificationRef.id;

            // Determine sender details based on public/alt event
            const senderName = isAlt && senderData?.username
                ? senderData.username
                : `${senderData?.firstName || ''} ${senderData?.lastName || ''}`.trim() || 'Someone';

            const senderProfileImage = isAlt
                ? senderData?.altProfileImageURL
                : senderData?.profileImageURL;

            // Generate path for navigation
            const path = generateNavigationPath(type, senderId, postId, commentId, isAlt, chatId);

            // Build notification data object, only including defined values
            const notificationData = {
                id: notificationId,
                senderId,
                type,
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
                isRead: false,
                title: title || generateTitle(type, senderName, count),
                body: body || generateBody(type, senderName, count, body),
                senderName: senderName,
                isAlt,
                path: path, // Add navigation path
            };

            // Only add optional fields if they have values
            if (postId) notificationData.postId = postId;
            if (commentId) notificationData.commentId = commentId;
            if (chatId) notificationData.chatId = chatId;
            if (messageId) notificationData.messageId = messageId;
            if (senderData?.username) notificationData.senderUsername = senderData.username;
            if (senderProfileImage) notificationData.senderProfileImage = senderProfileImage;
            if (senderData?.altProfileImageURL) notificationData.senderAltProfileImage = senderData.altProfileImageURL;
            if (count !== undefined && count !== null) notificationData.count = count;

            // Save notification to Firestore
            await notificationRef.set(notificationData);
            logger.log(` Notification saved to Firestore: ${notificationId}`);

            // Prepare push notification data (ensure all values are strings)
            const pushData = removeUndefinedValues({
                type,
                senderId,
                postId: postId || '',
                commentId: commentId || '',
                chatId: chatId || '',
                messageId: messageId || '',
                isAlt: isAlt ? 'true' : 'false',
                notificationId,
                path: path || '',
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
            logger.error(`Error creating notification: ${error}`);
            throw error;
        }
    }

    /**
     * Generate navigation path for notification
     */
    function generateNavigationPath(type, senderId, postId, commentId, isAlt, chatId) {
        switch (type) {
            case 'follow':
                // Use publicProfile as default for follow notifications
                return senderId ? `/publicProfile/${senderId}` : null;

            case 'newPost':
            case 'postLike':
            case 'postMilestone':
                return postId ? `/post/${postId}?isAlt=${isAlt}` : null;

            case 'comment':
                return postId ? `/post/${postId}?isAlt=${isAlt}&showComments=true` : null;

            case 'commentReply':
                // For comment threads, we'll use the route and pass data via extra in the app
                return postId && commentId ? `/commentThread` : null;

            case 'connectionRequest':
                return '/connection-requests'; // Match your router exactly

            case 'connectionAccepted':
                // Connection accepted usually means alt profile interaction
                return senderId ? `/altProfile/${senderId}` : null;

            case 'chatMessage':
                // Navigate directly to the specific chat
                return chatId ? `/chat?chatId=${chatId}` : null;

            default:
                return null;
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
            case 'chatMessage':
                return senderName;
            default:
                return 'New Notification';
        }
    }

    /**
     * Generate notification body based on type
     */
    function generateBody(type, senderName = 'Someone', count = null, customBody = null) {
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
            case 'chatMessage':
                return customBody || `${senderName} sent you a message`;
            default:
                return 'You have a new notification';
        }
    }

    // ========== CLOUD FUNCTIONS FOR NOTIFICATION QUERIES ==========

    /**
     * Get notifications for a user with pagination (Cloud Function)
     */
    const getNotifications = onCall(async (request) => {
        if (!request.auth) {
            throw new functions.https.HttpsError('unauthenticated', 'User must be logged in');
        }

        const userId = request.auth.uid;
        const {
            limit = 20,
            lastNotificationId = null,
            filterType = null,
            onlyUnread = false,
            markAsRead = false
        } = request.data;

        try {
            logger.log(`Getting notifications for user: ${userId}, limit: ${limit}, markAsRead: ${markAsRead}`);

            let query = firestore
                .collection('notifications')
                .doc(userId)
                .collection('userNotifications')
                .orderBy('timestamp', 'desc');

            // Apply type filter if provided
            if (filterType) {
                query = query.where('type', '==', filterType);
            }

            // Apply read status filter if requested
            if (onlyUnread) {
                query = query.where('isRead', '==', false);
            }

            // Apply pagination
            if (lastNotificationId) {
                const lastDoc = await firestore
                    .collection('notifications')
                    .doc(userId)
                    .collection('userNotifications')
                    .doc(lastNotificationId)
                    .get();

                if (lastDoc.exists) {
                    query = query.startAfter(lastDoc);
                }
            }

            query = query.limit(limit);

            const snapshot = await query.get();
            const notifications = [];
            const batch = firestore.batch();
            let hasBatchOperations = false;

            for (const doc of snapshot.docs) {
                const data = doc.data();
                const notification = {
                    id: doc.id,
                    ...data,
                    timestamp: data.timestamp?.toDate()?.getTime() || Date.now()
                };

                notifications.push(notification);

                // Mark as read if requested and not already read
                if (markAsRead && !data.isRead) {
                    batch.update(doc.ref, {
                        isRead: true,
                        readAt: admin.firestore.FieldValue.serverTimestamp()
                    });
                    hasBatchOperations = true;
                    notification.isRead = true; // Update local object too
                }
            }

            // Execute batch update if there are operations
            if (hasBatchOperations) {
                await batch.commit();
                logger.log(`Marked ${notifications.filter(n => !n.isRead).length} notifications as read`);
            }

            // Get updated unread count
            const unreadCount = await getUnreadCount(userId);

            logger.log(`Retrieved ${notifications.length} notifications for user ${userId}`);

            return {
                notifications,
                unreadCount,
                hasMore: notifications.length === limit,
                lastNotificationId: notifications.length > 0 ? notifications[notifications.length - 1].id : null
            };

        } catch (error) {
            logger.error(`Error getting notifications for user ${userId}:`, error);
            throw new functions.https.HttpsError('internal', `Failed to get notifications: ${error.message}`);
        }
    });

    /**
     * Get unread notification count (Cloud Function)
     */
    const getUnreadNotificationCount = onCall(async (request) => {
        if (!request.auth) {
            throw new functions.https.HttpsError('unauthenticated', 'User must be logged in');
        }

        const userId = request.auth.uid;

        try {
            const count = await getUnreadCount(userId);
            return { unreadCount: count };
        } catch (error) {
            logger.error(`Error getting unread count for user ${userId}:`, error);
            throw new functions.https.HttpsError('internal', `Failed to get unread count: ${error.message}`);
        }
    });

    /**
     * Mark notifications as read (Enhanced Cloud Function)
     */
    const markNotificationsAsRead = onCall(async (request) => {
        if (!request.auth) {
            throw new functions.https.HttpsError('unauthenticated', 'User must be logged in');
        }

        const userId = request.auth.uid;
        const { notificationIds = null } = request.data;

        try {
            if (notificationIds && Array.isArray(notificationIds) && notificationIds.length > 0) {
                // Mark specific notifications as read
                const batch = firestore.batch();

                for (const id of notificationIds) {
                    const notificationRef = firestore
                        .collection('notifications')
                        .doc(userId)
                        .collection('userNotifications')
                        .doc(id);

                    // Verify notification exists before updating
                    const notificationDoc = await notificationRef.get();
                    if (notificationDoc.exists) {
                        batch.update(notificationRef, {
                            isRead: true,
                            readAt: admin.firestore.FieldValue.serverTimestamp()
                        });
                    }
                }

                await batch.commit();
                const unreadCount = await getUnreadCount(userId);

                return {
                    success: true,
                    count: notificationIds.length,
                    unreadCount
                };
            } else {
                // Mark all notifications as read
                const notificationsSnapshot = await firestore
                    .collection('notifications')
                    .doc(userId)
                    .collection('userNotifications')
                    .where('isRead', '==', false)
                    .get();

                if (notificationsSnapshot.empty) {
                    return { success: true, count: 0, unreadCount: 0 };
                }

                const batch = firestore.batch();
                notificationsSnapshot.docs.forEach(doc => {
                    batch.update(doc.ref, {
                        isRead: true,
                        readAt: admin.firestore.FieldValue.serverTimestamp()
                    });
                });

                await batch.commit();

                return {
                    success: true,
                    count: notificationsSnapshot.size,
                    unreadCount: 0
                };
            }
        } catch (error) {
            logger.error('Error marking notifications as read:', error);
            throw new functions.https.HttpsError('internal', error.message);
        }
    });

    /**
     * Update FCM token (Cloud Function)
     */
    const updateFCMToken = onCall(async (request) => {
        if (!request.auth) {
            throw new functions.https.HttpsError('unauthenticated', 'User must be logged in');
        }

        const userId = request.auth.uid;
        const { fcmToken } = request.data;

        if (!fcmToken) {
            throw new functions.https.HttpsError('invalid-argument', 'FCM token is required');
        }

        try {
            await firestore.collection('users').doc(userId).update({
                fcmToken: fcmToken,
                fcmTokenUpdatedAt: admin.firestore.FieldValue.serverTimestamp()
            });

            logger.log(` Updated FCM token for user ${userId}`);
            return { success: true };
        } catch (error) {
            logger.error(`Error updating FCM token for user ${userId}:`, error);
            throw new functions.https.HttpsError('internal', error.message);
        }
    });

    // Return existing triggers plus new cloud functions
    return {
        // Existing triggers (keep all the existing ones from your original code)
        onNewFollower: onDocumentCreated("following/{followerId}/userFollowing/{followedId}",
            async (event) => {
                const followerId = event.params.followerId;
                const followedId = event.params.followedId;

                console.log(`=== FOLLOW NOTIFICATION TRIGGER FIRED ===`);
                console.log(`📋 Follower: ${followerId}, Followed: ${followedId}`);
                console.log(`🕐 Timestamp: ${new Date().toISOString()}`);

                logger.log(`👥 New follow: ${followerId} → ${followedId}`);


                await createNotification({
                    recipientId: followedId,
                    senderId: followerId,
                    type: 'follow',
                });
            }),

        onNewPost: onDocumentCreated("posts/{postId}", async (event) => {
            const postData = event.data.data();
            const authorId = postData.authorId;
            const postId = event.params.postId;

            if (postData.isAlt === true) {
                logger.log(`Skipping alt post notification for ${postId}`);
                return;
            }

            logger.log(`📝 New post created: ${postId} by ${authorId}`);

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

            const notificationPromises = [];

            for (const followerDoc of followersSnapshot.docs) {
                const followerId = followerDoc.id;

                notificationPromises.push(
                    createNotification({
                        recipientId: followerId,
                        senderId: authorId,
                        type: 'newPost',
                        postId: postId,
                        isAlt: false,
                    })
                );

                if (notificationPromises.length >= 10) {
                    await Promise.all(notificationPromises);
                    notificationPromises.length = 0;
                }
            }

            if (notificationPromises.length > 0) {
                await Promise.all(notificationPromises);
            }

            logger.log(` Post notifications sent for ${postId}`);
        }),

        onPostLike: onDocumentCreated("likes/{postId}/userInteractions/{userId}",
            async (event) => {
                const postId = event.params.postId;
                const likerId = event.params.userId;
                console.log(`=== LIKE NOTIFICATION TRIGGER FIRED ===`);
                console.log(`📋 Post: ${postId}, Liker: ${likerId}`);
                console.log(`🕐 Timestamp: ${new Date().toISOString()}`);

                logger.log(`❤️ Post liked: ${postId} by ${likerId}`);

                let postSnapshot = await firestore.collection('posts').doc(postId).get();
                let isAlt = false;

                if (!postSnapshot.exists) {
                    postSnapshot = await firestore.collection('altPosts').doc(postId).get();
                    isAlt = true;
                }

                if (!postSnapshot.exists) {
                    logger.error(`Post ${postId} not found for like notification`);
                    return;
                }

                const postData = postSnapshot.data();
                const authorId = postData.authorId;

                if (likerId === authorId) {
                    logger.log(`Skipping self-like for post ${postId}`);
                    return;
                }

                await createNotification({
                    recipientId: authorId,
                    senderId: likerId,
                    type: 'postLike',
                    postId: postId,
                    isAlt,
                });

                const currentLikeCount = postData.likeCount || 0;
                const milestones = [10, 25, 50, 100, 500, 1000];

                if (milestones.includes(currentLikeCount)) {
                    logger.log(`🎉 Milestone reached: ${currentLikeCount} likes for post ${postId}`);

                    await createNotification({
                        recipientId: authorId,
                        senderId: authorId,
                        type: 'postMilestone',
                        postId: postId,
                        count: currentLikeCount,
                        isAlt,
                    });
                }
            }),

        onNewComment: onDocumentCreated("comments/{postId}/postComments/{commentId}",
            async (event) => {
                const postId = event.params.postId;
                const commentId = event.params.commentId;
                const commentData = event.data.data();

                logger.log(`💬 New comment: ${commentId} on post ${postId}`);

                const commenterId = commentData.authorId;

                if (commentData.parentId) {
                    const parentCommentSnapshot = await firestore
                        .collection('comments')
                        .doc(postId)
                        .collection('postComments')
                        .doc(commentData.parentId)
                        .get();

                    if (parentCommentSnapshot.exists) {
                        const parentCommentData = parentCommentSnapshot.data();
                        const parentCommentAuthorId = parentCommentData.authorId;

                        if (commenterId !== parentCommentAuthorId) {
                            await createNotification({
                                recipientId: parentCommentAuthorId,
                                senderId: commenterId,
                                type: 'commentReply',
                                postId: postId,
                                commentId: commentId,
                                isAlt: commentData.isAltPost || false,
                            });
                        }
                    }
                } else {
                    let postSnapshot = await firestore.collection('posts').doc(postId).get();
                    let isAlt = false;

                    if (!postSnapshot.exists) {
                        postSnapshot = await firestore.collection('altPosts').doc(postId).get();
                        isAlt = true;
                    }

                    if (postSnapshot.exists) {
                        const postData = postSnapshot.data();
                        const postAuthorId = postData.authorId;

                        if (commenterId !== postAuthorId) {
                            await createNotification({
                                recipientId: postAuthorId,
                                senderId: commenterId,
                                type: 'comment',
                                postId: postId,
                                commentId: commentId,
                                isAlt,
                            });
                        }
                    }
                }
            }),

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
                });
            }),

        onConnectionAccepted: onDocumentUpdated("altConnectionRequests/{userId}/requests/{requesterId}",
            async (event) => {
                const after = event.data.after.data();
                const before = event.data.before.data();

                if (before.status === 'pending' && after.status === 'accepted') {
                    const userId = event.params.userId;
                    const requesterId = event.params.requesterId;

                    logger.log(` Connection accepted: ${userId} accepted ${requesterId}`);

                    await createNotification({
                        recipientId: requesterId,
                        senderId: userId,
                        type: 'connectionAccepted',
                        isAlt: true,
                    });
                }
            }),

        // Chat message notification trigger
        onNewChatMessage: onDocumentCreated("chatMessages/{chatId}/messages/{messageId}",
            async (event) => {
                const chatId = event.params.chatId;
                const messageId = event.params.messageId;
                const messageData = event.data.data();

                logger.log(`💬 New chat message: ${messageId} in chat ${chatId}`);

                const senderId = messageData.senderId;
                const content = messageData.content || '';
                const timestamp = messageData.timestamp;

                // Get chat participants using new single collection architecture
                // For direct chats, chatId format is "userId1_userId2"
                const chatIdParts = chatId.split('_');

                if (chatIdParts.length !== 2) {
                    logger.log(`Unsupported chat format: ${chatId} (group chats not yet supported)`);
                    return;
                }

                // For direct chats, determine recipient from chatId
                const [user1, user2] = chatIdParts;
                const recipientId = user1 === senderId ? user2 : user1;

                if (!recipientId || recipientId === senderId) {
                    logger.log(`Could not determine recipient for chat ${chatId}`);
                    return;
                }

                logger.log(`💬 Sending notification to recipient: ${recipientId}`);

                // Don't notify if recipient is currently in the chat (you can enhance this with presence detection)

                // Get sender info
                const senderSnapshot = await firestore.collection('users').doc(senderId).get();
                const senderData = senderSnapshot.exists ? senderSnapshot.data() : null;
                const senderName = senderData ? `${senderData.firstName || ''} ${senderData.lastName || ''}`.trim() || 'Someone' : 'Someone';

                // Create notification
                await createNotification({
                    recipientId: recipientId,
                    senderId: senderId,
                    type: 'chatMessage',
                    title: senderName,
                    body: content.length > 50 ? content.substring(0, 47) + '...' : content || 'Sent you a message',
                    chatId: chatId,
                    messageId: messageId
                });
            }),

        // New Cloud Functions
        getNotifications,
        getUnreadNotificationCount,
        markNotificationsAsRead,
        updateFCMToken,
        debugFCMToken,

        // Existing functions
        deleteNotifications: onCall(async (request) => {
            if (!request.auth) {
                throw new functions.https.HttpsError('unauthenticated', 'User must be logged in');
            }

            const userId = request.auth.uid;
            const { notificationIds } = request.data;

            try {
                if (!notificationIds || !Array.isArray(notificationIds)) {
                    throw new functions.https.HttpsError('invalid-argument', 'notificationIds must be an array');
                }

                const batch = firestore.batch();
                const verifiedIds = [];

                for (const id of notificationIds) {
                    const notificationRef = firestore
                        .collection('notifications')
                        .doc(userId)
                        .collection('userNotifications')
                        .doc(id);
                    const notificationDoc = await notificationRef.get();

                    if (notificationDoc.exists) {
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
                logger.error('Error deleting notifications:', error);
                throw new functions.https.HttpsError('internal', error.message);
            }
        }),

        cleanupOldNotifications: onSchedule("0 0 1 * *", async (event) => {
            const thirtyDaysAgo = new Date();
            thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

            try {
                // Use collection group query to find old notifications across all users
                const oldNotificationsSnapshot = await firestore
                    .collectionGroup('userNotifications')
                    .where('timestamp', '<', thirtyDaysAgo)
                    .limit(500) // Process in batches to avoid timeout
                    .get();

                if (oldNotificationsSnapshot.empty) {
                    logger.log('No old notifications to clean up');
                    return;
                }

                logger.log(`Cleaning up ${oldNotificationsSnapshot.size} old notifications`);

                const batch = firestore.batch();
                oldNotificationsSnapshot.docs.forEach(doc => {
                    batch.delete(doc.ref);
                });

                await batch.commit();
                logger.log(` Cleaned up ${oldNotificationsSnapshot.size} old notifications`);
            } catch (error) {
                logger.error('Error cleaning up old notifications:', error);
            }
        })
    };
};