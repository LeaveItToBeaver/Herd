const functions = require('firebase-functions');
const { onDocumentCreated, onDocumentDeleted, onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { onCall } = require("firebase-functions/v2/https");
const logger = functions.logger;


/**
 * Factory function that creates and returns all notification functions
 * @param {object} admin - Initialized Firebase Admin SDK
 * @returns {object} Object containing all notification functions
 */
module.exports = function (admin) {
    const firestore = admin.firestore();

    /**
     * Helper function to send push notification
     */
    async function sendPushNotification(userId, title, body, data) {
        try {
            // Get user's FCM token
            const userSnapshot = await firestore.collection('users').doc(userId).get();
            const userData = userSnapshot.data();

            if (!userData || !userData.fcmToken) {
                logger.log(`No FCM token found for user ${userId}`);
                return;
            }

            // Rest of the implementation as before...
            // Get user's notification settings
            const settingsSnapshot = await firestore
                .collection('notificationSettings')
                .doc(userId)
                .get();

            const settings = settingsSnapshot.exists ? settingsSnapshot.data() : null;

            // Check if user has notifications enabled
            if (settings && !settings.pushNotificationsEnabled) {
                logger.log(`Push notifications disabled for user ${userId}`);
                return;
            }

            // Check if user has muted notifications
            if (settings && settings.mutedUntil && settings.mutedUntil.toDate() > new Date()) {
                logger.log(`Notifications muted for user ${userId} until ${settings.mutedUntil.toDate()}`);
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
                logger.log(`${notificationType} notifications disabled for user ${userId}`);
                return;
            }

            // Create message
            const message = {
                token: userData.fcmToken,
                notification: {
                    title,
                    body,
                },
                data: {
                    ...data,
                    notificationId: data.notificationId || '',
                    click_action: 'FLUTTER_NOTIFICATION_CLICK',
                },
                android: {
                    priority: 'high',
                    notification: {
                        channelId: 'high_importance_channel',
                        priority: 'high',
                        defaultSound: true,
                        defaultVibrateTimings: true,
                    },
                },
                apns: {
                    payload: {
                        aps: {
                            sound: 'default',
                            badge: 1,
                        },
                    },
                },
            };

            // Send message
            const response = await admin.messaging().send(message);
            logger.log('Successfully sent notification:', response);
        } catch (error) {
            logger.error('Error sending notification:', error);
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
            // Rest of implementation...
            // Get sender information
            const senderSnapshot = await firestore.collection('users').doc(senderId).get();
            const senderData = senderSnapshot.exists ? senderSnapshot.data() : null;

            // Create notification document
            const notificationRef = firestore.collection('notifications').doc();
            const notificationId = notificationRef.id;

            // Determine sender details based on public/alt event
            const senderName = isAlt
                ? senderData?.username
                : `${senderData?.firstName || ''} ${senderData?.lastName || ''}`.trim();

            const senderProfileImage = isAlt
                ? senderData?.altProfileImageURL
                : senderData?.profileImageURL;

            const notificationData = {
                id: notificationId,
                recipientId,
                senderId,
                type,
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
                isRead: false,
                title: title || generateTitle(type, senderName),
                body: body || generateBody(type, senderName, count),
                postId,
                commentId,
                senderName: senderName || 'Someone',
                senderUsername: senderData?.username,
                senderProfileImage,
                senderAltProfileImage: senderData?.altProfileImageURL,
                isAlt,
                count,
            };

            // Save notification to Firestore
            await notificationRef.set(notificationData);

            // Send push notification
            await sendPushNotification(
                recipientId,
                notificationData.title,
                notificationData.body,
                {
                    type,
                    senderId,
                    postId: postId || '',
                    commentId: commentId || '',
                    isAlt: isAlt ? 'true' : 'false',
                    notificationId
                }
            );

            return notificationData;
        } catch (error) {
            logger.error('Error creating notification:', error);
            throw error;
        }
    }

    /**
     * Generate notification title based on type
     */
    function generateTitle(type, senderName = 'Someone') {
        switch (type) {
            case 'follow':
                return 'New Follower';
            case 'newPost':
                return 'New Post';
            case 'postLike':
                return 'New Like';
            case 'comment':
                return 'New Comment';
            case 'commentReply':
                return 'New Reply';
            case 'connectionRequest':
                return 'Connection Request';
            case 'connectionAccepted':
                return 'Connection Accepted';
            case 'postMilestone':
                return 'Post Milestone';
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
                return `${senderName} added a new post`;
            case 'postLike':
                return `${senderName} liked your post`;
            case 'comment':
                return `${senderName} commented on your post`;
            case 'commentReply':
                return `${senderName} replied to your comment`;
            case 'connectionRequest':
                return `${senderName} sent you a connection request`;
            case 'connectionAccepted':
                return `${senderName} accepted your connection request`;
            case 'postMilestone':
                return `Your post reached ${count} likes`;
            default:
                return 'You have a new notification';
        }
    }

    // Return an object with all the exported functions
    return {
        // When someone follows a user
        onNewFollower: onDocumentCreated("followers/{followedId}/userFollowers/{followerId}",
            async (event) => {
                const followedId = event.params.followedId;
                const followerId = event.params.followerId;

                await createNotification({
                    recipientId: followedId,
                    senderId: followerId,
                    type: 'follow',
                });
            }),

        // When someone creates a new post (notify followers)
        onNewPost: onDocumentCreated("posts/{postId}", async (event) => {
            const postData = event.data.data();
            const authorId = postData.authorId;
            const postId = event.params.postId;

            // Get followers
            const followersSnapshot = await firestore
                .collection('followers')
                .doc(authorId)
                .collection('userFollowers')
                .get();

            // Create batch for multiple notifications
            const batch = firestore.batch();
            const notifications = [];

            // Prepare notifications for each follower
            for (const followerDoc of followersSnapshot.docs) {
                const followerId = followerDoc.id;

                const notificationRef = firestore.collection('notifications').doc();

                // Create notification data
                const notificationData = {
                    id: notificationRef.id,
                    recipientId: followerId,
                    senderId: authorId,
                    type: 'newPost',
                    timestamp: admin.firestore.FieldValue.serverTimestamp(),
                    isRead: false,
                    postId,
                    senderName: postData.authorName || '',
                    senderUsername: postData.authorUsername,
                    senderProfileImage: postData.authorProfileImageURL,
                    isAlt: false,
                };

                batch.set(notificationRef, notificationData);
                notifications.push(notificationData);
            }

            // Commit batch write
            await batch.commit();

            // Send push notifications to each follower
            for (const notification of notifications) {
                await sendPushNotification(
                    notification.recipientId,
                    'New Post',
                    `${notification.senderName || 'Someone'} shared a new post`,
                    {
                        type: 'newPost',
                        senderId: authorId,
                        postId,
                        notificationId: notification.id,
                        isAlt: false,
                    }
                );
            }
        }),

        // Rest of the exported functions...
        // When someone likes a post
        onPostLike: onDocumentCreated("likes/{postId}/users/{userId}",
            async (event) => {
                const postId = event.params.postId;
                const likerId = event.params.userId;

                // Get post data
                const postSnapshot = await firestore.collection('posts').doc(postId).get();
                if (!postSnapshot.exists) {
                    // Also check alt posts
                    const altPostSnapshot = await firestore.collection('altPosts').doc(postId).get();
                    if (!altPostSnapshot.exists) {
                        logger.error(`Post ${postId} not found for like notification`);
                        return;
                    }

                    const postData = altPostSnapshot.data();
                    const authorId = postData.authorId;

                    // Skip if user likes their own post
                    if (likerId === authorId) return;

                    await createNotification({
                        recipientId: authorId,
                        senderId: likerId,
                        type: 'postLike',
                        postId,
                        isAlt: true,
                    });

                    return;
                }

                const postData = postSnapshot.data();
                const authorId = postData.authorId;

                // Skip if user likes their own post
                if (likerId === authorId) return;

                await createNotification({
                    recipientId: authorId,
                    senderId: likerId,
                    type: 'postLike',
                    postId,
                    isAlt: false,
                });

                // Check for milestone (e.g., 10, 50, 100 likes)
                const likesCount = await firestore
                    .collection('likes')
                    .doc(postId)
                    .collection('users')
                    .count()
                    .get();

                const likesCollectionPath = `likes/${postId}/userInteractions/${likerId}`;

                const count = likesCount.data().count;
                const likesCountSnapshot = await firestore.collection(isAlt ? 'altPosts' : 'posts').doc(postId).get();
                const currentLikeCount = likesCountSnapshot.data().likeCount || 0;


                const milestones = [10, 50, 100, 500, 1000];

                if (milestones.includes(currentLikeCount)) {
                    await createNotification({
                        recipientId: authorId,
                        senderId: null,
                        type: 'postMilestone',
                        postId,
                        count: currentLikeCount,
                        isAlt: false,
                    });
                }
            }),

        // When someone comments on a post
        onNewComment: onDocumentCreated("comments/{postId}/postComments/{commentId}",
            async (event) => {
                const postId = event.params.postId;
                const commentId = event.params.commentId;
                const commentData = event.data.data();

                // Skip if there's no parent comment (it's a direct post comment)
                if (!commentData.parentId) {
                    // This is a comment on a post, notify post author
                    const postSnapshot = await firestore.collection('posts').doc(postId).get();
                    let postData, isAlt = false;

                    if (!postSnapshot.exists) {
                        // Check alt posts
                        const altPostSnapshot = await firestore.collection('altPosts').doc(postId).get();
                        if (!altPostSnapshot.exists) {
                            logger.error(`Post ${postId} not found for comment notification`);
                            return;
                        }
                        postData = altPostSnapshot.data();
                        isAlt = true;
                    } else {
                        postData = postSnapshot.data();
                    }

                    const authorId = postData.authorId;
                    const commenterId = commentData.authorId;

                    // Skip if user comments on their own post
                    if (commenterId === authorId) return;

                    await createNotification({
                        recipientId: authorId,
                        senderId: commenterId,
                        type: 'comment',
                        postId,
                        commentId,
                        isAlt,
                    });
                } else {
                    // This is a reply to a comment, notify comment author
                    const parentCommentId = commentData.parentId;
                    const parentCommentSnapshot = await firestore
                        .collection('comments')
                        .doc(postId)
                        .collection('postComments')
                        .doc(parentCommentId)
                        .get();

                    if (!parentCommentSnapshot.exists) {
                        logger.error(`Parent comment ${parentCommentId} not found for reply notification`);
                        return;
                    }

                    const parentCommentData = parentCommentSnapshot.data();
                    const parentCommentAuthorId = parentCommentData.authorId;
                    const replyAuthorId = commentData.authorId;

                    // Skip if user replies to their own comment
                    if (replyAuthorId === parentCommentAuthorId) return;

                    await createNotification({
                        recipientId: parentCommentAuthorId,
                        senderId: replyAuthorId,
                        type: 'commentReply',
                        postId,
                        commentId,
                        isAlt: commentData.isAltPost || false,
                    });
                }
            }),

        // When someone sends a connection request
        onConnectionRequest: onDocumentCreated("altConnectionRequests/{userId}/requests/{requesterId}",
            async (event) => {
                const userId = event.params.userId;
                const requesterId = event.params.requesterId;

                await createNotification({
                    recipientId: userId,
                    senderId: requesterId,
                    type: 'connectionRequest',
                    isAlt: true,
                });
            }),

        // When someone accepts a connection request
        onConnectionAccepted: onDocumentUpdated("altConnectionRequests/{userId}/requests/{requesterId}",
            async (event) => {
                const after = event.data.after.data();
                const before = event.data.before.data();

                // Only trigger when status changes from pending to accepted
                if (before.status === 'pending' && after.status === 'accepted') {
                    const userId = event.params.userId;
                    const requesterId = event.params.requesterId;

                    await createNotification({
                        recipientId: requesterId,
                        senderId: userId,
                        type: 'connectionAccepted',
                        isAlt: true,
                    });
                }
            }),

        // Mark notifications as read in bulk
        markNotificationsAsRead: onCall(async (request) => {
            // Authenticate the user
            if (!request.auth) { // <<< Use request.auth
                throw new functions.https.HttpsError(
                    'unauthenticated',
                    'User must be logged in to mark notifications as read'
                );
            }

            const userId = request.auth.uid;
            const { notificationIds } = request.data;

            try {
                // If specific IDs are provided, mark only those
                if (notificationIds && Array.isArray(notificationIds) && notificationIds.length > 0) {
                    const batch = firestore.batch();

                    for (const id of notificationIds) {
                        const notificationRef = firestore.collection('notifications').doc(id);
                        batch.update(notificationRef, { isRead: true });
                    }

                    await batch.commit();
                    return { success: true, count: notificationIds.length };
                }
                // Otherwise mark all unread notifications as read
                else {
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
                        batch.update(doc.ref, { isRead: true });
                    });

                    await batch.commit();
                    return { success: true, count: notificationsSnapshot.size };
                }
            } catch (error) {
                logger.error('Error marking notifications as read:', error);
                throw new functions.https.HttpsError('internal', error.message);
            }
        }),

        // Delete notifications
        deleteNotifications: onCall(async (request) => {
            // Authenticate the user
            if (!request.auth) { // <<< Use request.auth
                throw new functions.https.HttpsError(
                    'unauthenticated',
                    'User must be logged in to delete notifications'
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

                // Verify notification ownership
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
                logger.error('Error deleting notifications:', error);
                throw new functions.https.HttpsError('internal', error.message);
            }
        })
    };
};