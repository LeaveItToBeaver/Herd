const { onDocumentCreated, onDocumentDeleted } = require("firebase-functions/v2/firestore");
const { logger } = require("firebase-functions");
const { admin, firestore } = require('./admin_init'); // Assuming admin_init.js
const { hotAlgorithm, findPostMediaItems } = require('./utils');

// 1. Trigger for public posts
exports.distributePublicPost = onDocumentCreated(
    "posts/{postId}",
    async (event) => {
        const postId = event.params.postId;
        const postData = event.data.data();

        // Validate post data
        if (!postData || !postData.authorId) {
            logger.error(`Invalid post data for ID: ${postId}`);
            return null;
        }

        // Calculate initial hot score
        const initialHotScore = hotAlgorithm.calculateHotScore(
            0, // New posts start with 0 net votes
            postData.createdAt ? postData.createdAt.toDate() : new Date()
        );

        // Add feedType and hotScore
        //    const enhancedPostData = {
        //      ...postData,
        //      hotScore: initialHotScore,
        //      feedType: 'public'
        //    };

        try {
            let enhancedPostData = {
                ...postData,
                hotScore: initialHotScore,
                feedType: 'public'
            };

            const mediaItems = await findPostMediaItems(postId, postData.authorId, false);

            if (mediaItems && mediaItems.length > 0) {
                logger.info(`Found ${mediaItems.length} media items for post ${postId}`);
                enhancedPostData.mediaItems = mediaItems;
                // Update the source post with media items
                await event.data.ref.update({ mediaItems });
            }

            // Get followers
            const followersSnapshot = await firestore
                .collection("followers")
                .doc(postData.authorId)
                .collection("userFollowers")
                .get();

            const targetUserIds = followersSnapshot.docs.map(doc => doc.id);

            // Add author to recipient list (they see their own posts)
            if (!targetUserIds.includes(postData.authorId)) {
                targetUserIds.push(postData.authorId);
            }

            // Fan out to followers' feeds
            await fanOutToUserFeeds(postId, enhancedPostData, targetUserIds);
            logger.info(`Distributed public post ${postId} to ${targetUserIds.length} users`);

            return null;
        } catch (error) {
            logger.error(`Error distributing public post ${postId}:`, error);
            throw error;
        }
    }
);

/**
 * Remove post from all feeds when the post is deleted
 */
exports.removeDeletedPost = onDocumentDeleted(
    "posts/{postId}",
    async (event) => {
        const postId = event.params.postId;
        const postData = event.data.data();

        if (!postData) {
            logger.error(`No post data found for deleted ID: ${postId}`);
            return null;
        }

        try {
            // Find all user feeds containing this post
            const feedQuery = firestore
                .collectionGroup("feed")
                .where("__name__", "==", postId)
                .select(); // Use select() to minimize data read

            const feedEntries = await feedQuery.get();

            if (feedEntries.empty) {
                logger.info(`No feed entries found for deleted post ${postId}`);
                return null;
            }

            logger.info(`Removing deleted post ${postId} from ${feedEntries.size} feeds`);

            // Batch delete from all feeds
            const MAX_BATCH_SIZE = 500;
            let batch = firestore.batch();
            let operationCount = 0;

            for (const doc of feedEntries.docs) {
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

            logger.info(`Successfully removed deleted post ${postId} from all feeds`);
            return null;
        } catch (error) {
            logger.error(`Error removing deleted post ${postId}:`, error);
            throw error;
        }
    }
);


// 2. Trigger for alt posts
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

        // Calculate initial hot score
        const initialHotScore = hotAlgorithm.calculateHotScore(
            0,
            postData.createdAt ? postData.createdAt.toDate() : new Date()
        );

        try {
            let enhancedPostData = {
                ...postData,
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

// 3. Trigger for herd posts
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

            // REFACTORED APPROACH: Store complete data only in altPosts
            await firestore.collection('altPosts').doc(postId).set(enhancedPostData);

            // REFACTORED APPROACH: Store only minimal reference data in herdPosts
            const minimalPostData = {
                id: postId,
                authorId: postData.authorId,
                createdAt: postData.createdAt,
                hotScore: initialHotScore,
                sourcePostRef: 'altPosts/' + postId  // Reference to the source of truth
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
    });

// Helper function for fan-out operations with minimal data
async function fanOutToUserFeeds(postId, postData, userIds) {
    if (userIds.length === 0) return;

    // Extract only the minimal necessary data
    const minimalPostData = {
        id: postId,
        authorId: postData.authorId,
        authorName: postData.authorName || null,
        authorUsername: postData.authorUsername || null,
        authorProfileImageURL: postData.authorProfileImageURL || null,
        tags: postData.tags || [],
        isNSFW: postData.isNSFW || false,
        isAlt: postData.isAlt || false,
        feedType: postData.feedType,
        createdAt: postData.createdAt,
        herdId: postData.herdId || null,
        // Reference fields that help identify where to look up the full post
        sourceCollection: postData.isAlt ? 'altPosts' :
            (postData.herdId ? 'herdPosts' : 'posts'),
        // Store the hotScore to maintain sort order without recalculating
        hotScore: postData.hotScore || 0
    };

    // Batch processing
    const MAX_BATCH_SIZE = 500; // Firestore limit
    let batch = firestore.batch();
    let operationCount = 0;

    for (const userId of userIds) {
        const userFeedRef = firestore
            .collection("userFeeds")
            .doc(userId)
            .collection("feed")
            .doc(postId);

        batch.set(userFeedRef, minimalPostData);
        operationCount++;

        // If batch is full, commit and reset
        if (operationCount >= MAX_BATCH_SIZE) {
            await batch.commit();
            batch = firestore.batch();
            operationCount = 0;
        }
    }

    // Commit any remaining operations
    if (operationCount > 0) {
        await batch.commit();
    }
}