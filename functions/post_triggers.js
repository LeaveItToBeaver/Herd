const { onDocumentCreated, onDocumentDeleted } = require("firebase-functions/v2/firestore");

const { logger } = require("firebase-functions");
const { admin, firestore } = require('./admin_init'); // Assuming admin_init.js
const { hotAlgorithm, findPostMediaItems } = require('./utils');

exports.onPublicPostCreated = onDocumentCreated("posts/{postId}", async (event) => {
    const postId = event.params.postId;
    const postData = event.data.data();

    if (!postData || !postData.authorId) {
        logger.error(`Invalid post data for ID: ${postId}`);
        return null;
    }

    logger.info(`Processing new public post ${postId}`);
    try {
        const incrementPromise = firestore.collection('users').doc(postData.authorId).update({
            totalPosts: admin.firestore.FieldValue.increment(1),
            updatedAt: admin.firestore.FieldValue.serverTimestamp()
        });

        const distributionPromise = (async () => {
            const initialHotScore = hotAlgorithm.calculateHotScore(0, postData.createdAt ? postData.createdAt.toDate() : new Date());
            let enhancedPostData = { ...postData, id: postId, hotScore: initialHotScore, feedType: 'public' };
            const mediaItems = await findPostMediaItems(postId, postData.authorId, false);

            if (mediaItems && mediaItems.length > 0) {
                enhancedPostData.mediaItems = mediaItems;
                await event.data.ref.update({ mediaItems });
            }

            const followersSnapshot = await firestore.collection("followers").doc(postData.authorId).collection("userFollowers").get();
            const targetUserIds = followersSnapshot.docs.map(doc => doc.id);
            if (!targetUserIds.includes(postData.authorId)) {
                targetUserIds.push(postData.authorId);
            }
            await fanOutToUserFeeds(postId, enhancedPostData, targetUserIds);
        })();

        // Run both tasks in parallel for max efficiency
        await Promise.all([incrementPromise, distributionPromise]);
        logger.info(`Successfully processed and distributed public post ${postId}`);

    } catch (error) {
        logger.error(`Error processing new public post ${postId}:`, error);
        throw error;
    }
});

exports.incrementAltPostCount = onDocumentCreated(
    "altPosts/{postId}",
    async (event) => {
        const postData = event.data.data();

        if (!postData || !postData.authorId) {
            logger.error(`Invalid alt post data for incrementing count`);
            return null;
        }

        try {
            await firestore.collection('users').doc(postData.authorId).update({
                altTotalPosts: admin.firestore.FieldValue.increment(1),
                updatedAt: admin.firestore.FieldValue.serverTimestamp()
            });

            logger.info(`Incremented altTotalPosts for user ${postData.authorId}`);
            return null;
        } catch (error) {
            logger.error(`Error incrementing altTotalPosts for user ${postData.authorId}:`, error);
            throw error;
        }
    }
);

exports.decrementPublicPostCount = onDocumentDeleted(
    "posts/{postId}",
    async (event) => {
        const postData = event.data.data();

        if (!postData || !postData.authorId) {
            logger.error(`Invalid deleted post data for decrementing count`);
            return null;
        }

        try {
            await firestore.collection('users').doc(postData.authorId).update({
                totalPosts: admin.firestore.FieldValue.increment(-1),
                updatedAt: admin.firestore.FieldValue.serverTimestamp()
            });

            logger.info(`Decremented totalPosts for user ${postData.authorId}`);
            return null;
        } catch (error) {
            logger.error(`Error decrementing totalPosts for user ${postData.authorId}:`, error);
            throw error;
        }
    }
);

exports.decrementAltPostCount = onDocumentDeleted(
    "altPosts/{postId}",
    async (event) => {
        const postData = event.data.data();

        if (!postData || !postData.authorId) {
            logger.error(`Invalid deleted alt post data for decrementing count`);
            return null;
        }

        try {
            await firestore.collection('users').doc(postData.authorId).update({
                altTotalPosts: admin.firestore.FieldValue.increment(-1),
                updatedAt: admin.firestore.FieldValue.serverTimestamp()
            });

            logger.info(`Decremented altTotalPosts for user ${postData.authorId}`);
            return null;
        } catch (error) {
            logger.error(`Error decrementing altTotalPosts for user ${postData.authorId}:`, error);
            throw error;
        }
    }
);

exports.incrementHerdPostCount = onDocumentCreated(
    "herdPosts/{herdId}/posts/{postId}",
    async (event) => {
        const postData = event.data.data();

        if (!postData || !postData.authorId) {
            logger.error(`Invalid herd post data for incrementing count`);
            return null;
        }

        try {
            // Herd posts count as alt posts
            await firestore.collection('users').doc(postData.authorId).update({
                altTotalPosts: admin.firestore.FieldValue.increment(1),
                updatedAt: admin.firestore.FieldValue.serverTimestamp()
            });

            logger.info(`Incremented altTotalPosts for herd post by user ${postData.authorId}`);
            return null;
        } catch (error) {
            logger.error(`Error incrementing altTotalPosts for herd post by user ${postData.authorId}:`, error);
            throw error;
        }
    }
);

/**
 * Remove post from all feeds when the post is deleted
 */
exports.removeDeletedPost = onDocumentDeleted(
    "posts/{postId}", // This trigger is for when a post in the main 'posts' collection is deleted
    async (event) => {
        const postId = event.params.postId;
        // const postData = event.data.data(); // Data of the deleted document

        // We need to remove this postId from all userFeeds/{userId}/feed/{postId}
        // This requires a collectionGroup query.

        try {
            const feedEntriesQuery = firestore
                .collectionGroup("feed") // Query all collections named 'feed'
                .where("id", "==", postId);

            const feedEntriesSnapshot = await feedEntriesQuery.get();

            if (feedEntriesSnapshot.empty) {
                logger.info(`No feed entries found for deleted post ${postId} to remove.`);
                return null;
            }

            logger.info(`Removing deleted post ${postId} from ${feedEntriesSnapshot.size} feeds.`);

            const MAX_BATCH_SIZE = 500;
            let batch = firestore.batch();
            let operationCount = 0;

            for (const doc of feedEntriesSnapshot.docs) {
                batch.delete(doc.ref);
                operationCount++;

                if (operationCount >= MAX_BATCH_SIZE) {
                    await batch.commit();
                    batch = firestore.batch();
                    operationCount = 0;
                }
            }

            if (operationCount > 0) {
                await batch.commit();
            }

            logger.info(`Successfully removed deleted post ${postId} from user feeds.`);
            return null;
        } catch (error) {
            logger.error(`Error removing deleted post ${postId} from feeds:`, error);
            throw error;
        }
    }
);


exports.onPublicPostDeleted = onDocumentDeleted(
    "posts/{postId}",
    async (event) => {
        const postId = event.params.postId;
        const postData = event.data.data();

        if (!postData || !postData.authorId) {
            logger.error(`Invalid public post data for ID: ${postId}. Cannot clean up.`);
            return null;
        }

        logger.info(`Starting cleanup for public post ${postId}`);
        try {
            const decrementPromise = firestore.collection('users').doc(postData.authorId).update({
                totalPosts: admin.firestore.FieldValue.increment(-1),
                updatedAt: admin.firestore.FieldValue.serverTimestamp()
            });

            await Promise.all([
                decrementPromise,
                removePostFromAllFeeds(postId),
                cleanupPostInteractions(postId),
                cleanupPostComments(postId),
            ]);

            logger.info(`Successfully cleaned up public post ${postId}`);
            return null;
        } catch (error) {
            logger.error(`Error cleaning up public post ${postId}:`, error);
            throw error;
        }
    }
);

/**
 * Handles all cleanup when an ALT post is deleted.
 * Note: A herd post's data is also stored in 'altPosts', so this function
 * will run when a herd post is deleted via its 'altPosts' entry.
 */
exports.onAltPostDeleted = onDocumentDeleted("altPosts/{postId}", async (event) => {
    const postId = event.params.postId;
    const postData = event.data.data();

    if (!postData || !postData.authorId) {
        logger.error(`Invalid altPost data for ID: ${postId}. Cannot clean up.`);
        return null;
    }

    logger.info(`Starting cleanup for alt post ${postId}`);
    try {
        // This will decrement 'altTotalPosts' for both regular alt posts AND herd posts
        const decrementPromise = firestore.collection('users').doc(postData.authorId).update({
            altTotalPosts: admin.firestore.FieldValue.increment(-1),
            updatedAt: admin.firestore.FieldValue.serverTimestamp()
        });

        await Promise.all([
            decrementPromise,
            removePostFromAllFeeds(postId),
            cleanupPostInteractions(postId),
            cleanupPostComments(postId),
            // If it was a herd post, this will remove the original reference in the herdPosts subcollection
            cleanupHerdPostReference(postId, postData.herdId),
        ]);

        logger.info(`Successfully cleaned up alt post ${postId}`);
        return null;
    } catch (error) {
        logger.error(`Error cleaning up alt post ${postId}:`, error);
        throw error;
    }
});

/**
 * Handles cleanup specific to when a HERD post reference is deleted.
 * This function is crucial for keeping counts accurate.
 */
exports.onHerdPostDeleted = onDocumentDeleted("herdPosts/{herdId}/posts/{postId}", async (event) => {
    const herdId = event.params.herdId;
    const postId = event.params.postId;
    const postData = event.data.data();

    if (!postData) {
        logger.error(`Invalid herd post data for ID: ${postId}. Cannot clean up.`);
        return null;
    }

    logger.info(`Starting cleanup for herd post ${postId} in herd ${herdId}`);
    try {
        await Promise.all([
            // Delete the main post data from the 'altPosts' collection.
            // This will trigger the onAltPostDeleted function to handle the rest of the cleanup.
            firestore.collection('altPosts').doc(postId).delete(),

            // Decrement the herd's specific post counter.
            firestore.collection('herds').doc(herdId).update({
                postCount: admin.firestore.FieldValue.increment(-1)
            })
        ]);

        logger.info(`Successfully cleaned up herd post ${postId} from herd ${herdId}`);
        return null;
    } catch (error) {
        logger.error(`Error cleaning up herd post ${postId}:`, error);
        throw error;
    }
});

// Helper function to remove post from all user feeds
async function removePostFromAllFeeds(postId) {
    try {
        // Use collectionGroup to find all instances across all user feeds
        const feedEntriesQuery = firestore
            .collectionGroup("feed")
            .where("id", "==", postId);

        const feedEntriesSnapshot = await feedEntriesQuery.get();

        if (feedEntriesSnapshot.empty) {
            logger.info(`No feed entries found for post ${postId}`);
            return;
        }

        logger.info(`Removing post ${postId} from ${feedEntriesSnapshot.size} feeds`);

        // Batch delete for efficiency
        const MAX_BATCH_SIZE = 500;
        let batch = firestore.batch();
        let operationCount = 0;

        for (const doc of feedEntriesSnapshot.docs) {
            batch.delete(doc.ref);
            operationCount++;

            if (operationCount >= MAX_BATCH_SIZE) {
                await batch.commit();
                batch = firestore.batch();
                operationCount = 0;
            }
        }

        if (operationCount > 0) {
            await batch.commit();
        }

        logger.info(`Successfully removed post ${postId} from all feeds`);
    } catch (error) {
        logger.error(`Error removing post ${postId} from feeds:`, error);
        throw error;
    }
}

// Helper function to clean up all interactions (likes/dislikes)
async function cleanupPostInteractions(postId) {
    try {
        const batch = firestore.batch();

        // Delete all likes
        const likesSnapshot = await firestore
            .collection('likes')
            .doc(postId)
            .collection('userInteractions')
            .get();

        likesSnapshot.docs.forEach(doc => {
            batch.delete(doc.ref);
        });

        // Delete all dislikes
        const dislikesSnapshot = await firestore
            .collection('dislikes')
            .doc(postId)
            .collection('userInteractions')
            .get();

        dislikesSnapshot.docs.forEach(doc => {
            batch.delete(doc.ref);
        });

        // Delete the parent documents
        batch.delete(firestore.collection('likes').doc(postId));
        batch.delete(firestore.collection('dislikes').doc(postId));

        await batch.commit();
        logger.info(`Cleaned up interactions for post ${postId}`);
    } catch (error) {
        logger.error(`Error cleaning up interactions for post ${postId}:`, error);
        throw error;
    }
}

// Helper function to clean up all comments
async function cleanupPostComments(postId) {
    try {
        const commentsSnapshot = await firestore
            .collection('comments')
            .doc(postId)
            .collection('postComments')
            .get();

        if (commentsSnapshot.empty) {
            return;
        }

        const batch = firestore.batch();

        // Delete all comment documents
        commentsSnapshot.docs.forEach(doc => {
            batch.delete(doc.ref);
        });

        // Delete the parent document
        batch.delete(firestore.collection('comments').doc(postId));

        await batch.commit();
        logger.info(`Cleaned up ${commentsSnapshot.size} comments for post ${postId}`);
    } catch (error) {
        logger.error(`Error cleaning up comments for post ${postId}:`, error);
        throw error;
    }
}

// Helper function to clean up herd post reference when alt post is deleted
async function cleanupHerdPostReference(postId, herdId) {
    if (!herdId) return;

    try {
        await firestore
            .collection('herdPosts')
            .doc(herdId)
            .collection('posts')
            .doc(postId)
            .delete();

        logger.info(`Cleaned up herd post reference for ${postId} in herd ${herdId}`);
    } catch (error) {
        logger.error(`Error cleaning up herd post reference:`, error);
        // Don't throw - this is optional cleanup
    }
}

exports.distributeAltPost = onDocumentCreated(
    "altPosts/{postId}",
    async (event) => {
        const postId = event.params.postId;
        const postData = event.data.data();

        // Validate post data
        if (!postData || !postData.authorId) {
            logger.error(`Invalid alt post data for ID: ${postId}`);
            return null;
        }

        if (postData.herdId) {
            logger.info(`Skipping distributeAltPost for herd post ${postId} - handled by distributeHerdPost`);
            return null;
        }


        // Calculate initial hot score
        const initialHotScore = hotAlgorithm.calculateHotScore(
            0,
            postData.createdAt ? postData.createdAt.toDate() : new Date()
        );

        try {
            let enhancedPostData = {
                ...postData,
                id: postId,
                hotScore: initialHotScore,
                feedType: 'alt'
            };

            const mediaItems = await findPostMediaItems(postId, postData.authorId, true);

            if (mediaItems && mediaItems.length > 0) {
                logger.info(`Found ${mediaItems.length} media items for post ${postId}`);
                enhancedPostData.mediaItems = mediaItems;
                // Update the source post with media items
                await event.data.ref.update({ mediaItems });
            }

            await fanOutToUserFeeds(postId, enhancedPostData, [postData.authorId]);

            logger.info(`Added alt post ${postId} to author's feed`);
            return null;
        } catch (error) {
            logger.error(`Error distributing alt post ${postId}:`, error);
            throw error;
        }
    }
);

exports.distributeHerdPost = onDocumentCreated(
    "herdPosts/{herdId}/posts/{postId}",
    async (event) => {
        const herdId = event.params.herdId;
        const postId = event.params.postId;
        const postData = event.data.data();

        // Validate post data
        if (!postData || !postData.authorId) {
            logger.error(`Invalid herd post data for ID: ${postId}`);
            return null;
        }

        try {
            // Get herd details to check if private
            const herdDoc = await firestore.collection("herds").doc(herdId).get();
            const herdData = herdDoc.data();
            const isPrivateHerd = herdData?.isPrivate || false;

            // Calculate initial hot score
            const initialHotScore = hotAlgorithm.calculateHotScore(
                0,
                postData.createdAt ? postData.createdAt.toDate() : new Date()
            );

            // Add feedType and hotScore
            let enhancedPostData = {
                ...postData,
                hotScore: initialHotScore,
                feedType: 'herd',
                herdId: herdId,
                herdName: herdData?.name || '',
                herdProfileImageURL: herdData?.profileImageURL || ''
            };

            // Find media items
            const mediaItems = await findPostMediaItems(postId, postData.authorId, false);
            if (mediaItems && mediaItems.length > 0) {
                enhancedPostData.mediaItems = mediaItems;
            }

            await firestore.collection('altPosts').doc(postId).set(enhancedPostData);

            const minimalPostData = {
                id: postId,
                authorId: postData.authorId,
                createdAt: postData.createdAt,
                hotScore: initialHotScore,
                sourcePostRef: 'altPosts/' + postId,  // Reference to the source of truth
                herdId: herdId
            };

            // Update the herd post document with minimal data
            await event.data.ref.update(minimalPostData);

            // Fan out minimal references to herd members' feeds
            const herdMembersSnapshot = await firestore
                .collection("herdMembers")
                .doc(herdId)
                .collection("members")
                .get();

            const herdMemberIds = herdMembersSnapshot.docs.map(doc => doc.id);
            await fanOutReferencesToUserFeeds(postId, minimalPostData, herdMemberIds);

            return null;
        } catch (error) {
            logger.error(`Error distributing herd post ${postId}:`, error);
            throw error;
        }
    }
);

// Helper function for fan-out operations with minimal reference data
async function fanOutReferencesToUserFeeds(postId, minimalPostData, userIds) {
    if (userIds.length === 0) return;

    // Extract only the minimal necessary reference data
    const referenceData = {
        id: postId,
        authorId: minimalPostData.authorId,
        createdAt: minimalPostData.createdAt,
        hotScore: minimalPostData.hotScore || 0,
        feedType: 'herd',
        herdId: minimalPostData.herdId,
        sourceCollection: 'altPosts',  // Where to find the full post data
    };

    // Batch processing
    const MAX_BATCH_SIZE = 500;
    let batch = firestore.batch();
    let operationCount = 0;

    for (const userId of userIds) {
        const userFeedRef = firestore
            .collection("userFeeds")
            .doc(userId)
            .collection("feed")
            .doc(postId);

        batch.set(userFeedRef, referenceData);
        operationCount++;

        if (operationCount >= MAX_BATCH_SIZE) {
            await batch.commit();
            batch = firestore.batch();
            operationCount = 0;
        }
    }

    if (operationCount > 0) {
        await batch.commit();
    }
}

exports.populateHerdPostMediaItems = onDocumentCreated(
    "herdPosts/{herdId}/posts/{postId}",
    async (event) => {
        const herdId = context.params.herdId;
        const postId = context.params.postId;

        // Reuse the same core logic as above, but specifically for herd posts
        // This is needed because the wildcard pattern in the first function
        // can't directly match nested collections

        const postData = snapshot.data();

        // If mediaItems array already exists and has items, skip
        if (postData.mediaItems && Array.isArray(postData.mediaItems) && postData.mediaItems.length > 0) {
            logger.info(`Herd post ${postId} already has ${postData.mediaItems.length} media items`);
            return null;
        }

        try {
            const userId = postData.authorId;
            const herdId = postData.herdId || null;
            const isAlt = postData.isAlt === true;

            if (!userId) {
                logger.error(`Post ${postId} has no authorId`);
                return null;
            }

            logger.info(`Processing media items for herd post ${postId} in herd ${herdId}`);

            if (!userId) {
                logger.error(`Herd post ${postId} has no authorId`);
                return null;
            }

            // Same storage path calculation and file listing logic
            const baseStoragePath = isAlt
                ? `users/${userId}/alt/posts/${postId}`
                : `users/${userId}/posts/${postId}`;

            const storageRef = admin.storage().bucket().getFiles({
                prefix: baseStoragePath
            });

            const [files] = await storageRef;

            if (files.length === 0) {
                logger.info(`No files found in storage for post ${postId}`);
                return null;
            }

            logger.info(`Found ${files.length} files for post ${postId}`);

            // Group files by subdirectory (each media item has fullres and possibly thumbnail)
            const mediaGroups = {};

            for (const file of files) {
                // Extract the media ID from the path
                // Format: users/{userId}/[alt/]posts/{postId}-{mediaId}/[fullres|thumbnail].ext
                const filePath = file.name;
                const pathSegments = filePath.split('/');
                const lastSegment = pathSegments[pathSegments.length - 1];

                // Look for the pattern postId-mediaId in the path
                let mediaId = '0'; // Default if we can't extract
                const postWithMediaPattern = new RegExp(`${postId}-(\\d+)`);

                for (const segment of pathSegments) {
                    const match = segment.match(postWithMediaPattern);
                    if (match && match[1]) {
                        mediaId = match[1];
                        break;
                    }
                }

                if (!mediaGroups[mediaId]) {
                    mediaGroups[mediaId] = { id: mediaId };
                }

                // Determine if this is a fullres or thumbnail and get download URL
                if (lastSegment.includes('fullres')) {
                    // pull out the firebaseStorageDownloadTokens
                    const [metadata] = await file.getMetadata();
                    const token = metadata.metadata.firebaseStorageDownloadTokens;
                    const bucketName = admin.storage().bucket().name;
                    // must URL-encode the full “object” path
                    const pathEncoded = encodeURIComponent(file.name);
                    mediaGroups[mediaId].url =
                        `https://firebasestorage.googleapis.com/v0/b/${bucketName}/o/${pathEncoded}?alt=media&token=${token}`;
                }
                else if (lastSegment.includes('thumbnail')) {
                    const [metadata] = await file.getMetadata();
                    const token = metadata.metadata.firebaseStorageDownloadTokens;
                    const bucketName = admin.storage().bucket().name;
                    const pathEncoded = encodeURIComponent(file.name);
                    mediaGroups[mediaId].thumbnailUrl =
                        `https://firebasestorage.googleapis.com/v0/b/${bucketName}/o/${pathEncoded}?alt=media&token=${token}`;
                }
            }

            // Create mediaItems array from the groups
            const mediaItems = Object.values(mediaGroups)
                .filter(item => item.url) // Only include items with a URL
                .map(item => ({
                    id: item.id,
                    url: item.url,
                    thumbnailUrl: item.thumbnailUrl || item.url, // Use main URL as fallback
                    mediaType: item.mediaType || 'image'
                }));

            if (mediaItems.length === 0) {
                logger.info(`No valid media items found for post ${postId}`);
                return null;
            }

            logger.info(`Updating post ${postId} with ${mediaItems.length} media items`);


            // Update the herd post with mediaItems array
            await snapshot.ref.update({ mediaItems });

            logger.info(`Successfully updated herd post ${herdId}/${postId} with media items`);
            return { success: true };

        } catch (error) {
            logger.error(`Error populating media items for herd post ${herdId}/${postId}:`, error);
            return { success: false, error: error.message };
        }
    }
);

// Helper function for fan-out operations with minimal data
async function fanOutToUserFeeds(postId, postDataToFanOut, userIds) {
    if (!userIds || userIds.length === 0) {
        logger.info(`No user IDs provided for fan-out of post ${postId}.`);
        return;
    }
    if (!postDataToFanOut.feedType) {
        logger.error(`feedType is missing in postDataToFanOut for post ${postId}. Aborting fan-out.`);
        return;
    }


    // Extract only the minimal necessary data
    const feedEntryData = {
        id: postId, // Document ID in the feed will be the postId
        authorId: postDataToFanOut.authorId,
        createdAt: postDataToFanOut.createdAt,
        hotScore: postDataToFanOut.hotScore || 0,
        feedType: postDataToFanOut.feedType, // 'public', 'alt', or 'herd'

        // Fields for public/alt posts (full data)
        authorName: postDataToFanOut.authorName || null,
        authorUsername: postDataToFanOut.authorUsername || null,
        authorProfileImageURL: postDataToFanOut.authorProfileImageURL || null,
        content: postDataToFanOut.content || (postDataToFanOut.feedType !== 'herd' ? '' : undefined), // content might not be on minimal herd ref
        tags: postDataToFanOut.tags || (postDataToFanOut.feedType !== 'herd' ? [] : undefined),
        isNSFW: postDataToFanOut.isNSFW || false,
        mediaItems: postDataToFanOut.mediaItems || (postDataToFanOut.feedType !== 'herd' ? [] : undefined),
        likeCount: postDataToFanOut.likeCount || 0, // May not be on minimal herd ref initially
        dislikeCount: postDataToFanOut.dislikeCount || 0,
        commentCount: postDataToFanOut.commentCount || 0,

        // Fields specific to herd post references
        herdId: postDataToFanOut.herdId || null, // Will be null for public/alt
        sourceCollection: postDataToFanOut.sourceCollection || (postDataToFanOut.feedType === 'public' ? 'posts' : 'altPosts'), // Default for public/alt

        // Ensure isAlt is correctly set based on the source postData if available,
        // or based on feedType if it's an alt post.
        isAlt: postDataToFanOut.isAlt || (postDataToFanOut.feedType === 'alt'),
    };

    Object.keys(feedEntryData).forEach(key => {
        if (feedEntryData[key] === undefined) {
            delete feedEntryData[key];
        }
    });

    const MAX_BATCH_SIZE = 500;
    let batch = firestore.batch();
    let operationCount = 0;

    for (const userId of userIds) {
        const userFeedRef = firestore
            .collection("userFeeds")
            .doc(userId)
            .collection("feed")
            .doc(postId); // Use postId as the document ID in the feed

        batch.set(userFeedRef, feedEntryData);
        operationCount++;

        if (operationCount >= MAX_BATCH_SIZE) {
            await batch.commit();
            batch = firestore.batch();
            operationCount = 0;
        }
    }

    if (operationCount > 0) {
        await batch.commit();
    }
    logger.info(`Fanned out post ${postId} (type: ${feedEntryData.feedType}) to ${userIds.length} user feeds.`);
}