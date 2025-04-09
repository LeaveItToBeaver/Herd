const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { onDocumentCreated, onDocumentDeleted, onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { logger } = require("firebase-functions");

admin.initializeApp();
const firestore = admin.firestore();

// Hot algorithm implementation for post ranking - this stays mostly the same
const hotAlgorithm = {
  calculateHotScore: (netVotes, createdAt, decayFactor = 1.0) => {
    try {
      // Ensure createdAt is a valid Date
      if (createdAt?.toDate) createdAt = createdAt.toDate();
      if (!(createdAt instanceof Date)) createdAt = new Date();

      // Sanitize inputs to be valid numbers
      const sanitizedNetVotes = Number(netVotes) || 0;
      const sanitizedDecayFactor = Number(decayFactor) || 1.0;

      // Calculate components
      const sign = Math.sign(sanitizedNetVotes);
      const magnitude = Math.log10(Math.max(1, Math.abs(sanitizedNetVotes)));
      const timeSinceCreation = Math.max(1, (Date.now() - createdAt.getTime()) / 1000);
      const timeDecay = Math.pow(timeSinceCreation, -0.5) * sanitizedDecayFactor;

      // Calculate final score and check for NaN
      const score = sign * magnitude * timeDecay;

      // Debug logging (before return)
      logger.info(`Hot score calculation: netVotes=${sanitizedNetVotes}, timeDecay=${timeDecay}, score=${score}`);

      return isNaN(score) ? 0 : score;
    } catch (error) {
      logger.error('Error calculating hot score:', error);
      return 0; // Default safe value
    }
  },

  sortPosts: (posts, decayFactor = 1.0) => {
    try {
      return posts.sort((a, b) => {
        const aScore = hotAlgorithm.calculateHotScore(
          (a.likeCount || 0) - (a.dislikeCount || 0),
          a.createdAt,
          decayFactor
        );
        const bScore = hotAlgorithm.calculateHotScore(
          (b.likeCount || 0) - (b.dislikeCount || 0),
          b.createdAt,
          decayFactor
        );
        return bScore - aScore;
      });
    } catch (error) {
      logger.error('Error sorting posts:', error);
      return posts; // Return unsorted posts as fallback
    }
  }
};


/**
 * Deep sanitize function to recursively clean objects of NaN values
 */
function sanitizeData(obj) {
  // Handle primitive values
  if (obj === null || obj === undefined) {
    return obj;
  }
  if (typeof obj !== 'object') {
    // If it's a NaN number, return 0
    if (typeof obj === 'number' && isNaN(obj)) {
      return 0;
    }
    // Otherwise return the value unchanged
    return obj;
  }

  // Handle arrays
  if (Array.isArray(obj)) {
    // Check if this looks like a mediaItems array
    if (obj.length > 0 && obj[0] && typeof obj[0] === 'object' && (obj[0].url || obj[0].id)) {
      return obj.filter(item => item && item.url).map(item => sanitizeData(item));
    }
    return obj.map(item => sanitizeData(item));
  }
  // Handle objects
  const result = {};
  for (const [key, value] of Object.entries(obj)) {
    // Handle Firestore timestamps
    if (value && typeof value.toDate === 'function') {
      result[key] = value.toDate().getTime();
    }
    // Handle Date objects
    else if (value instanceof Date) {
      result[key] = value.getTime();
    }
    // Handle NaN values
    else if (typeof value === 'number' && isNaN(value)) {
      result[key] = 0;
    }
    // Recursively sanitize nested objects
    else if (typeof value === 'object' && value !== null) {
      result[key] = sanitizeData(value);
    }
    // Pass through other values
    else {
      result[key] = value;
    }
  }
  return result;
}

async function findPostMediaItems(postId, userId, isAlt) {
  try {
    // Determine the base storage path
    const baseStoragePath = isAlt
      ? `users/${userId}/alt/posts/${postId}`
      : `users/${userId}/posts/${postId}`;

    // List all files in the post's storage directory
    const [files] = await admin.storage().bucket().getFiles({
      prefix: baseStoragePath
    });

    if (files.length === 0) {
      logger.info(`No files found in storage for post ${postId}`);
      return [];
    }

    // Same processing logic you already have
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
        const [url] = await file.getSignedUrl({
          action: 'read',
          expires: '03-01-2500' // Far future expiration
        });
        mediaGroups[mediaId].url = url;

        // Determine media type from extension
        const extension = lastSegment.split('.').pop().toLowerCase();
        mediaGroups[mediaId].mediaType = extension === 'gif'
          ? 'gif'
          : ['jpg', 'jpeg', 'png', 'webp', 'bmp'].includes(extension)
            ? 'image'
            : ['mp4', 'mov', 'avi', 'mkv', 'webm'].includes(extension)
              ? 'video'
              : 'other';
      }
      else if (lastSegment.includes('thumbnail')) {
        const [url] = await file.getSignedUrl({
          action: 'read',
          expires: '03-01-2500'
        });
        mediaGroups[mediaId].thumbnailUrl = url;
      }
    }

    // Create and return mediaItems array
    return Object.values(mediaGroups)
      .filter(item => item.url)
      .map(item => ({
        id: item.id,
        url: item.url,
        thumbnailUrl: item.thumbnailUrl || item.url,
        mediaType: item.mediaType || 'image'
      }));
  } catch (error) {
    logger.error(`Error finding media items for post ${postId}:`, error);
    return [];
  }
}


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

    // Add feedType and hotScore
    //    const enhancedPostData = {
    //      ...postData,
    //      hotScore: initialHotScore,
    //      feedType: 'alt'
    //    };

    try {
      let enhancedPostData = {
        ...postData,
        hotScore: initialHotScore,
        feedType: 'alt'
      };

      const mediaItems = await findPostMediaItems(postId, postData.authorId, false);

      if (mediaItems && mediaItems.length > 0) {
        logger.info(`Found ${mediaItems.length} media items for post ${postId}`);
        enhancedPostData.mediaItems = mediaItems;
        // Update the source post with media items
        await event.data.ref.update({ mediaItems });
      }

      // For alt posts, add to global alt feed (which already happened via direct write)
      // Just need to add to author's personal feed
      await firestore
        .collection("userFeeds")
        .doc(postData.authorId)
        .collection("feed")
        .doc(postId)
        .set(enhancedPostData);

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

    // Calculate initial hot score
    const initialHotScore = hotAlgorithm.calculateHotScore(
      0,
      postData.createdAt ? postData.createdAt.toDate() : new Date()
    );

    // Add feedType and hotScore
    //    const enhancedPostData = {
    //      ...postData,
    //      hotScore: initialHotScore,
    //      feedType: 'herd',
    //      herdId: herdId  // Ensure herdId is always set
    //    };

    try {
      // Get herd details to check if private
      const herdDoc = await firestore.collection("herds").doc(herdId).get();
      const herdData = herdDoc.data();
      const isPrivateHerd = herdData?.isPrivate || false;

      let enhancedPostData = {
        ...postData,
        hotScore: initialHotScore,
        feedType: 'herd',
        herdId: herdId
      };

      // Find all media items associated with this post
      const mediaItems = await findPostMediaItems(postId, postData.authorId, false);

      if (mediaItems && mediaItems.length > 0) {
        logger.info(`Found ${mediaItems.length} media items for post ${postId}`);
        enhancedPostData.mediaItems = mediaItems;

        // Update the source post with media items
        await event.data.ref.update({ mediaItems });
      }



      // Add herd name and image to post data for easier rendering
      enhancedPostData.herdName = herdData?.name || '';
      enhancedPostData.herdProfileImageURL = herdData?.profileImageURL || '';

      // Fan out to herd members
      const herdMembersSnapshot = await firestore
        .collection("herdMembers")
        .doc(herdId)
        .collection("members")
        .get();

      const herdMemberIds = herdMembersSnapshot.docs.map(doc => doc.id);
      await fanOutToUserFeeds(postId, enhancedPostData, herdMemberIds);

      // For public herds, add to the global alt feed for discovery
      if (!isPrivateHerd) {
        await firestore.collection('altPosts').doc(postId).set(enhancedPostData);
        logger.info(`Added herd post ${postId} to global alt feed (public herd)`);
      }

      logger.info(`Distributed herd post ${postId} to ${herdMemberIds.length} members`);
      return null;
    } catch (error) {
      logger.error(`Error distributing herd post ${postId}:`, error);
      throw error;
    }
  }
);

///**
// * Cloud Function to populate mediaItems for all post types
// * This runs after post creation and scans Storage for related media files
// */
//exports.populateMediaItems = functions.firestore
//  .document('{postCollection}/{postId}')
//  .onCreate(async (snapshot, context) => {
//    const postId = context.params.postId;
//    const collection = context.params.postCollection;
//
//    // Skip if this isn't a post collection we care about
//    if (!['posts', 'altPosts'].includes(collection) && !collection.includes('herdPosts')) {
//      logger.info(`Skipping non-post collection: ${collection}`);
//      return null;
//    }
//
//    const postData = snapshot.data();
//
//    // If mediaItems array already exists and has items, skip
//    if (postData.mediaItems && Array.isArray(postData.mediaItems) && postData.mediaItems.length > 0) {
//      logger.info(`Post ${postId} already has ${postData.mediaItems.length} media items`);
//      return null;
//    }
//
//    try {
//      // Identify post type and user
//      const userId = postData.authorId;
//      const isAlt = postData.isAlt === true || collection === 'altPosts';
//      const herdId = postData.herdId || null;
//
//      if (!userId) {
//        logger.error(`Post ${postId} has no authorId`);
//        return null;
//      }
//
//      logger.info(`Processing media items for ${isAlt ? 'alt' : 'public'} post ${postId} by user ${userId}`);
//
//      // Determine the base storage path
//      const baseStoragePath = isAlt
//        ? `users/${userId}/alt/posts/${postId}`
//        : `users/${userId}/posts/${postId}`;
//
//      // List all files in the post's storage directory
//      const storageRef = admin.storage().bucket().getFiles({
//        prefix: baseStoragePath
//      });
//
//      const [files] = await storageRef;
//
//      if (files.length === 0) {
//        logger.info(`No files found in storage for post ${postId}`);
//        return null;
//      }
//
//      logger.info(`Found ${files.length} files for post ${postId}`);
//
//      // Group files by subdirectory (each media item has fullres and possibly thumbnail)
//      const mediaGroups = {};
//
//      for (const file of files) {
//        // Extract the media ID from the path
//        // Format: users/{userId}/[alt/]posts/{postId}-{mediaId}/[fullres|thumbnail].ext
//        const filePath = file.name;
//        const pathSegments = filePath.split('/');
//        const lastSegment = pathSegments[pathSegments.length - 1];
//
//        // Look for the pattern postId-mediaId in the path
//        let mediaId = '0'; // Default if we can't extract
//        const postWithMediaPattern = new RegExp(`${postId}-(\\d+)`);
//
//        for (const segment of pathSegments) {
//          const match = segment.match(postWithMediaPattern);
//          if (match && match[1]) {
//            mediaId = match[1];
//            break;
//          }
//        }
//
//        if (!mediaGroups[mediaId]) {
//          mediaGroups[mediaId] = { id: mediaId };
//        }
//
//        // Determine if this is a fullres or thumbnail and get download URL
//        if (lastSegment.includes('fullres')) {
//          const [url] = await file.getSignedUrl({
//            action: 'read',
//            expires: '03-01-2500' // Far future expiration
//          });
//          mediaGroups[mediaId].url = url;
//
//          // Determine media type from extension
//          const extension = lastSegment.split('.').pop().toLowerCase();
//          mediaGroups[mediaId].mediaType = extension === 'gif'
//            ? 'gif'
//            : ['jpg', 'jpeg', 'png', 'webp', 'bmp'].includes(extension)
//              ? 'image'
//              : ['mp4', 'mov', 'avi', 'mkv', 'webm'].includes(extension)
//                ? 'video'
//                : 'other';
//        }
//        else if (lastSegment.includes('thumbnail')) {
//          const [url] = await file.getSignedUrl({
//            action: 'read',
//            expires: '03-01-2500'
//          });
//          mediaGroups[mediaId].thumbnailUrl = url;
//        }
//      }
//
//      // Create mediaItems array from the groups
//      const mediaItems = Object.values(mediaGroups)
//        .filter(item => item.url) // Only include items with a URL
//        .map(item => ({
//          id: item.id,
//          url: item.url,
//          thumbnailUrl: item.thumbnailUrl || item.url, // Use main URL as fallback
//          mediaType: item.mediaType || 'image'
//        }));
//
//      if (mediaItems.length === 0) {
//        logger.info(`No valid media items found for post ${postId}`);
//        return null;
//      }
//
//      logger.info(`Updating post ${postId} with ${mediaItems.length} media items`);
//
//      // Update the post with mediaItems array based on collection type
//      if (collection === 'posts') {
//        await snapshot.ref.update({ mediaItems });
//      } else if (collection === 'altPosts') {
//        await snapshot.ref.update({ mediaItems });
//      } else if (collection.includes('herdPosts')) {
//        // Handle herd posts - need to extract herdId from path
//        const herdId = context.resource.name.split('/').slice(-4, -3)[0];
//        await admin.firestore()
//          .collection('herdPosts')
//          .doc(herdId)
//          .collection('posts')
//          .doc(postId)
//          .update({ mediaItems });
//      }
//
//      logger.info(`Successfully updated post ${postId} with ${mediaItems.length} media items`);
//      return { success: true, mediaCount: mediaItems.length };
//
//    } catch (error) {
//      logger.error(`Error populating media items for post ${postId}:`, error);
//      return { success: false, error: error.message };
//    }
//  });

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
          const [url] = await file.getSignedUrl({
            action: 'read',
            expires: '03-01-2500' // Far future expiration
          });
          mediaGroups[mediaId].url = url;

          // Determine media type from extension
          const extension = lastSegment.split('.').pop().toLowerCase();
          mediaGroups[mediaId].mediaType = extension === 'gif'
            ? 'gif'
            : ['jpg', 'jpeg', 'png', 'webp', 'bmp'].includes(extension)
              ? 'image'
              : ['mp4', 'mov', 'avi', 'mkv', 'webm'].includes(extension)
                ? 'video'
                : 'other';
        }
        else if (lastSegment.includes('thumbnail')) {
          const [url] = await file.getSignedUrl({
            action: 'read',
            expires: '03-01-2500'
          });
          mediaGroups[mediaId].thumbnailUrl = url;
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

// Helper function for fan-out operations
async function fanOutToUserFeeds(postId, postData, userIds) {
  if (userIds.length === 0) return;

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

    batch.set(userFeedRef, {
      ...postData,
      mediaItems: postData.mediaItems || [] // Explicitly set mediaItems
    });
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

/**
 * Update post hot scores across all feeds when a post is liked/disliked
 */
exports.updatePostInFeeds = onDocumentUpdated(
  "posts/{postId}",
  async (event) => {
    const postId = event.params.postId;
    const beforeData = event.data.before.data();
    const afterData = event.data.after.data();

    // Only process if engagement metrics have changed
    if (
      beforeData.likeCount === afterData.likeCount &&
      beforeData.dislikeCount === afterData.dislikeCount
    ) {
      return null;
    }

    try {
      // Calculate new hot score
      const netVotes = afterData.likeCount - afterData.dislikeCount;
      const createdAt = afterData.createdAt.toDate();
      const updatedHotScore = hotAlgorithm.calculateHotScore(netVotes, createdAt);

      // Find all user feeds containing this post
      const feedQuery = firestore
        .collectionGroup("feed")
        .where("__name__", "==", postId)
        .select(); // Use select() to minimize data read

      const feedEntries = await feedQuery.get();

      if (feedEntries.empty) {
        logger.info(`No feed entries found for post ${postId}`);
        return null;
      }

      logger.info(`Updating hot score for post ${postId} in ${feedEntries.size} feeds`);

      // Batch update all feeds
      const MAX_BATCH_SIZE = 500;
      let batch = firestore.batch();
      let operationCount = 0;

      for (const doc of feedEntries.docs) {
        batch.update(doc.ref, { hotScore: updatedHotScore });
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

      logger.info(`Successfully updated post ${postId} hot score in all feeds`);
      return null;
    } catch (error) {
      logger.error(`Error updating post ${postId} in feeds:`, error);
      throw error;
    }
  }
);

/**
 * Handle post interactions (likes/dislikes) with the unified feed approach
 */
exports.handlePostInteraction = onCall({
  enforceAppCheck: false,
},
  async (request) => {
    const {
      postId,
      interactionType,
      feedType
    } = request.data;

    // Validate authentication
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'User must be logged in');
    }

    const userId = request.auth.uid;

    let postRef;

    if (feedType === 'public') {
      postRef = firestore.collection('posts').doc(postId);
    } else if (feedType === 'alt') {
      postRef = firestore.collection('altPosts').doc(postId);
    } else if (feedType === 'herd') {
      postRef = firestore.collection('herdPosts').doc(herdId).collection('posts').doc(postId);
    } else {
      throw new HttpsError('invalid-argument', 'Invalid feed type');
    }

    // Define interaction configurations here - make sure it's defined before use
    const interactions = {
      like: {
        incrementField: 'likeCount',
        decrementField: 'dislikeCount',
        collection: 'likes'
      },
      dislike: {
        incrementField: 'dislikeCount',
        decrementField: 'likeCount',
        collection: 'dislikes'
      }
    };

    // Validate interaction type early
    const config = interactions[interactionType];
    if (!config) {
      throw new HttpsError('invalid-argument', 'Invalid interaction type');
    }

    return firestore.runTransaction(async (transaction) => {
      // Get all document references first before any writes
      const postDoc = await transaction.get(postRef);

      if (!postDoc.exists) {
        throw new HttpsError('not-found', 'Post not found');
      }

      const postData = postDoc.data();

      const interactionRef = firestore
        .collection(config.collection)
        .doc(postId)
        .collection('userInteractions')
        .doc(userId);

      // Check current interaction state
      const currentInteraction = await transaction.get(interactionRef);
      const isCurrentlyInteracted = currentInteraction.exists;

      // Check if opposite interaction exists - do this read before any writes
      const oppositeCollection = interactionType === 'like' ? 'dislikes' : 'likes';
      const oppositeRef = firestore
        .collection(oppositeCollection)
        .doc(postId)
        .collection('userInteractions')
        .doc(userId);

      const oppositeInteraction = await transaction.get(oppositeRef);
      const hasOppositeInteraction = oppositeInteraction.exists;

      // NOW DO ALL WRITES AFTER ALL READS

      // Calculate the changes based on current state
      let likeChange = 0;
      let dislikeChange = 0;

      if (interactionType === 'like') {
        likeChange = isCurrentlyInteracted ? -1 : 1;
        dislikeChange = hasOppositeInteraction ? -1 : 0;
      } else { // dislike
        dislikeChange = isCurrentlyInteracted ? -1 : 1;
        likeChange = hasOppositeInteraction ? -1 : 0;
      }

      // Update post counts
      transaction.update(postRef, {
        likeCount: admin.firestore.FieldValue.increment(likeChange),
        dislikeCount: admin.firestore.FieldValue.increment(dislikeChange)
      });

      // Toggle user's interaction
      if (isCurrentlyInteracted) {
        transaction.delete(interactionRef);
      } else {
        transaction.set(interactionRef, {
          timestamp: admin.firestore.FieldValue.serverTimestamp()
        });
      }

      // Remove opposite interaction if it exists
      if (hasOppositeInteraction) {
        transaction.delete(oppositeRef);
      }

      // Calculate updated hot score with new values
      const updatedLikeCount = postData.likeCount + likeChange;
      const updatedDislikeCount = postData.dislikeCount + dislikeChange;
      const netVotes = updatedLikeCount - updatedDislikeCount;
      const updatedHotScore = hotAlgorithm.calculateHotScore(
        netVotes,
        postData.createdAt.toDate()
      );

      transaction.update(postRef, { hotScore: updatedHotScore });

      // If not the author, update user points
      if (postData.authorId !== userId) {
        const pointChange = isCurrentlyInteracted ? -1 : 1;
        const authorRef = firestore.collection('users').doc(postData.authorId);
        transaction.update(authorRef, {
          userPoints: admin.firestore.FieldValue.increment(pointChange)
        });
      }

      return {
        success: true,
        hotScore: updatedHotScore,
        isLiked: interactionType === 'like' && !isCurrentlyInteracted,
        isDisliked: interactionType === 'dislike' && !isCurrentlyInteracted
      };
    });
  });


/**
 * Get feed for a user with filtering options
 */
exports.getFeed = onCall(async (request) => {
  const {
    feedType = 'public',
    herdId = null,
    limit = 20,
    lastHotScore = null,
    lastPostId = null
  } = request.data;

  // Validate required userId
  const userId = request.data.userId;
  if (!userId) {
    throw new HttpsError('invalid-argument', 'User ID is required');
  }

  try {
    // Different query strategy based on feed type
    let postsResult = {};

    if (feedType === 'public') {
      postsResult = await getPublicFeed(userId, limit, lastHotScore, lastPostId);
    }
    else if (feedType === 'alt') {
      postsResult = await getAltFeed(limit, lastHotScore, lastPostId);
    }
    else if (herdId) {
      postsResult = await getHerdFeed(herdId, limit, lastHotScore, lastPostId);
    } else {
      postsResult = await getPublicFeed(userId, limit, lastHotScore, lastPostId);
    }

    // Deep sanitize the entire response to remove any NaN values
    const sanitizedResult = sanitizeData({
      posts: postsResult.posts,
      lastHotScore: postsResult.lastHotScore,
      lastPostId: postsResult.lastPostId
    });

    // Additional validation as a last resort
    if (sanitizedResult.lastHotScore !== undefined &&
      typeof sanitizedResult.lastHotScore === 'number' &&
      isNaN(sanitizedResult.lastHotScore)) {
      sanitizedResult.lastHotScore = 0;
    }

    return sanitizedResult;
  } catch (error) {
    logger.error(`Error getting feed for user ${userId}:`, error);
    throw new HttpsError('internal', `Failed to get feed: ${error.message}`);
  }
});

// Get public feed (personalized for each user)
async function getPublicFeed(userId, limit, lastHotScore, lastPostId) {
  let feedQuery = firestore
    .collection('userFeeds')
    .doc(userId)
    .collection('feed')
    .where('feedType', '==', 'public')
    .orderBy('hotScore', 'desc');

  // Apply pagination with validation
  if (lastHotScore !== null && lastPostId !== null && !isNaN(lastHotScore)) {
    feedQuery = feedQuery.startAfter(lastHotScore, lastPostId);
  }

  // Apply limit
  feedQuery = feedQuery.limit(limit);

  // Execute query
  const snapshot = await feedQuery.get();
  const posts = snapshot.docs.map(doc => {
    const data = doc.data();
    // Ensure hotScore is valid here
    if (data.hotScore === undefined || isNaN(data.hotScore)) {
      data.hotScore = 0;
    }
    return {
      id: doc.id,
      ...data
    };
  });

  // Make sure lastHotScore isn't NaN
  let finalLastHotScore = posts.length > 0 ? posts[posts.length - 1].hotScore : null;
  if (finalLastHotScore !== null && isNaN(finalLastHotScore)) {
    finalLastHotScore = 0;
  }

  return {
    posts,
    lastHotScore: finalLastHotScore,
    lastPostId: posts.length > 0 ? posts[posts.length - 1].id : null
  };
}

// Get alt feed (global, like Reddit's r/All)
async function getAltFeed(limit, lastHotScore, lastPostId) {
  // Query the global alt posts collection
  let feedQuery = firestore
    .collection('altPosts')
    .orderBy('hotScore', 'desc');

  // Apply pagination
  if (lastHotScore !== null && lastPostId !== null) {
    feedQuery = feedQuery.startAfter(lastHotScore, lastPostId);
  }

  // Apply limit
  feedQuery = feedQuery.limit(limit);

  // Execute query
  const snapshot = await feedQuery.get();
  const posts = snapshot.docs.map(doc => ({
    id: doc.id,
    ...doc.data()
  }));

  return {
    posts,
    lastHotScore: posts.length > 0 ? posts[posts.length - 1].hotScore : null,
    lastPostId: posts.length > 0 ? posts[posts.length - 1].id : null
  };
}

// Get herd-specific feed
async function getHerdFeed(herdId, limit, lastHotScore, lastPostId) {
  let feedQuery = firestore
    .collection('herdPosts')
    .doc(herdId)
    .collection('posts')
    .orderBy('hotScore', 'desc');

  // Apply pagination
  if (lastHotScore !== null && lastPostId !== null) {
    feedQuery = feedQuery.startAfter(lastHotScore, lastPostId);
  }

  // Apply limit
  feedQuery = feedQuery.limit(limit);

  // Execute query
  const snapshot = await feedQuery.get();
  const posts = snapshot.docs.map(doc => ({
    id: doc.id,
    ...doc.data()
  }));

  return {
    posts,
    lastHotScore: posts.length > 0 ? posts[posts.length - 1].hotScore : null,
    lastPostId: posts.length > 0 ? posts[posts.length - 1].id : null
  };
}

/**
 * Scheduled job to update hot scores for recent posts
 * Runs every hour to keep scores current
 */
exports.updateHotScores = onSchedule(
  "every 60 minutes",
  async (event) => {
    // Only process posts from the last 7 days
    const oneWeekAgo = new Date();
    oneWeekAgo.setDate(oneWeekAgo.getDate() - 7);

    try {
      // Query for posts with significant engagement
      const postsQuery = firestore
        .collection('posts')
        .where('createdAt', '>', oneWeekAgo)
        .where('likeCount', '>', 0) // Only posts with some engagement
        .limit(500); // Process in chunks

      const postsSnapshot = await postsQuery.get();

      if (postsSnapshot.empty) {
        logger.info('No posts found for hot score update');
        return null;
      }

      logger.info(`Updating hot scores for ${postsSnapshot.size} posts`);

      // Batch update
      const batch = firestore.batch();

      for (const doc of postsSnapshot.docs) {
        const postData = doc.data();
        const netVotes = postData.likeCount - (postData.dislikeCount || 0);

        const updatedHotScore = hotAlgorithm.calculateHotScore(
          netVotes,
          postData.createdAt.toDate()
        );

        // Only update if score has changed significantly
        if (!postData.hotScore || Math.abs(postData.hotScore - updatedHotScore) > 0.001) {
          batch.update(doc.ref, { hotScore: updatedHotScore });
        }
      }

      await batch.commit();
      logger.info('Hot score update completed successfully');
      return null;
    } catch (error) {
      logger.error('Error updating hot scores:', error);
      throw error;
    }
  }
);

/**
 * Update user feed when a follow/unfollow action occurs
 */
exports.handleFollowAction = onDocumentCreated(
  "followers/{followedId}/userFollowers/{followerId}",
  async (event) => {
    const followedId = event.params.followedId;
    const followerId = event.params.followerId;

    try {
      // When someone follows a user, add the followed user's recent public posts to follower's feed
      const recentPostsQuery = firestore
        .collection('posts')
        .where('authorId', '==', followedId)
        .where('isAlt', '==', false) // Only public posts
        .orderBy('createdAt', 'desc')
        .limit(20); // Limit to recent posts

      const postsSnapshot = await recentPostsQuery.get();

      if (postsSnapshot.empty) {
        logger.info(`No public posts found for user ${followedId}`);
        return null;
      }

      // Batch add posts to follower's feed
      const batch = firestore.batch();

      for (const doc of postsSnapshot.docs) {
        const postData = doc.data();

        // Add feedType metadata
        const enhancedPostData = {
          ...postData,
          feedType: 'public',
          hotScore: postData.hotScore || hotAlgorithm.calculateHotScore(
            postData.likeCount - (postData.dislikeCount || 0),
            postData.createdAt.toDate()
          )
        };

        const feedRef = firestore
          .collection('userFeeds')
          .doc(followerId)
          .collection('feed')
          .doc(doc.id);

        batch.set(feedRef, enhancedPostData);
      }

      await batch.commit();
      logger.info(`Added ${postsSnapshot.size} posts to feed of user ${followerId}`);
      return null;
    } catch (error) {
      logger.error(`Error handling follow action (${followerId} → ${followedId}):`, error);
      throw error;
    }
  }
);

/**
 * Clean up user's feed when they unfollow someone
 */
exports.handleUnfollowAction = onDocumentDeleted(
  "followers/{followedId}/userFollowers/{followerId}",
  async (event) => {
    const followedId = event.params.followedId;
    const followerId = event.params.followerId;

    try {
      // Query for the unfollowed user's posts in follower's feed
      const feedQuery = firestore
        .collection('userFeeds')
        .doc(followerId)
        .collection('feed')
        .where('authorId', '==', followedId)
        .where('feedType', '==', 'public');

      const feedSnapshot = await feedQuery.get();

      if (feedSnapshot.empty) {
        logger.info(`No posts from ${followedId} found in ${followerId}'s feed`);
        return null;
      }

      // Batch delete posts
      const batch = firestore.batch();

      for (const doc of feedSnapshot.docs) {
        batch.delete(doc.ref);
      }

      await batch.commit();
      logger.info(`Removed ${feedSnapshot.size} posts from ${followerId}'s feed`);
      return null;
    } catch (error) {
      logger.error(`Error handling unfollow action (${followerId} → ${followedId}):`, error);
      throw error;
    }
  }
);

/**
 * Handle alt connection creation - add alt posts to new connection's feed
 */
exports.handleAltConnection = onDocumentCreated(
  "altConnections/{userId}/userConnections/{connectionId}",
  async (event) => {
    const userId = event.params.userId;
    const connectionId = event.params.connectionId;

    try {
      // Add recent alt posts to the connection's feed
      const recentAltPostsQuery = firestore
        .collection('posts')
        .where('authorId', '==', userId)
        .where('isAlt', '==', true)
        .orderBy('createdAt', 'desc')
        .limit(20);

      const postsSnapshot = await recentAltPostsQuery.get();

      if (postsSnapshot.empty) {
        logger.info(`No alt posts found for user ${userId}`);
        return null;
      }

      // Batch add posts to connection's feed
      const batch = firestore.batch();

      for (const doc of postsSnapshot.docs) {
        const postData = doc.data();

        const enhancedPostData = {
          ...postData,
          feedType: 'alt',
          hotScore: postData.hotScore || hotAlgorithm.calculateHotScore(
            postData.likeCount - (postData.dislikeCount || 0),
            postData.createdAt.toDate()
          )
        };

        const feedRef = firestore
          .collection('userFeeds')
          .doc(connectionId)
          .collection('feed')
          .doc(doc.id);

        batch.set(feedRef, enhancedPostData);
      }

      await batch.commit();
      logger.info(`Added ${postsSnapshot.size} alt posts to feed of user ${connectionId}`);
      return null;
    } catch (error) {
      logger.error(`Error handling alt connection (${userId} → ${connectionId}):`, error);
      throw error;
    }
  }
);

/**
 * Handle alt connection removal - remove alt posts from feed
 */
exports.handleAltConnectionRemoval = onDocumentDeleted(
  "altConnections/{userId}/userConnections/{connectionId}",
  async (event) => {
    const userId = event.params.userId;
    const connectionId = event.params.connectionId;

    try {
      // Remove alt posts from the connection's feed
      const feedQuery = firestore
        .collection('userFeeds')
        .doc(connectionId)
        .collection('feed')
        .where('authorId', '==', userId)
        .where('feedType', '==', 'alt');

      const feedSnapshot = await feedQuery.get();

      if (feedSnapshot.empty) {
        logger.info(`No alt posts from ${userId} found in ${connectionId}'s feed`);
        return null;
      }

      // Batch delete posts
      const batch = firestore.batch();

      for (const doc of feedSnapshot.docs) {
        batch.delete(doc.ref);
      }

      await batch.commit();
      logger.info(`Removed ${feedSnapshot.size} alt posts from ${connectionId}'s feed`);
      return null;
    } catch (error) {
      logger.error(`Error handling alt connection removal (${userId} → ${connectionId}):`, error);
      throw error;
    }
  }
);

/**
 * Add/remove user from herd feed when joining/leaving a herd
 */
exports.handleHerdMembership = onDocumentCreated(
  "herdMembers/{herdId}/members/{userId}",
  async (event) => {
    const herdId = event.params.herdId;
    const userId = event.params.userId;

    try {
      // Query recent herd posts
      const herdPostsQuery = firestore
        .collection('posts')
        .where('herdId', '==', herdId)
        .orderBy('createdAt', 'desc')
        .limit(50);

      const postsSnapshot = await herdPostsQuery.get();

      if (postsSnapshot.empty) {
        logger.info(`No posts found for herd ${herdId}`);
        return null;
      }

      // Add herd posts to user's feed
      const batch = firestore.batch();

      for (const doc of postsSnapshot.docs) {
        const postData = doc.data();

        const enhancedPostData = {
          ...postData,
          feedType: 'herd',
          hotScore: postData.hotScore || hotAlgorithm.calculateHotScore(
            postData.likeCount - (postData.dislikeCount || 0),
            postData.createdAt.toDate()
          )
        };

        const feedRef = firestore
          .collection('userFeeds')
          .doc(userId)
          .collection('feed')
          .doc(doc.id);

        batch.set(feedRef, enhancedPostData);
      }

      await batch.commit();
      logger.info(`Added ${postsSnapshot.size} herd posts to feed of user ${userId}`);
      return null;
    } catch (error) {
      logger.error(`Error handling herd membership (${userId} joins ${herdId}):`, error);
      throw error;
    }
  }
);

/**
 * Clean up herd posts from user's feed when leaving a herd
 */
exports.handleHerdLeave = onDocumentDeleted(
  "herdMembers/{herdId}/members/{userId}",
  async (event) => {
    const herdId = event.params.herdId;
    const userId = event.params.userId;

    try {
      // Query for herd posts in user's feed
      const feedQuery = firestore
        .collection('userFeeds')
        .doc(userId)
        .collection('feed')
        .where('herdId', '==', herdId);

      const feedSnapshot = await feedQuery.get();

      if (feedSnapshot.empty) {
        logger.info(`No posts from herd ${herdId} found in ${userId}'s feed`);
        return null;
      }

      // Batch delete posts
      const batch = firestore.batch();

      for (const doc of feedSnapshot.docs) {
        batch.delete(doc.ref);
      }

      await batch.commit();
      logger.info(`Removed ${feedSnapshot.size} herd posts from ${userId}'s feed`);
      return null;
    } catch (error) {
      logger.error(`Error handling herd leave (${userId} leaves ${herdId}):`, error);
      throw error;
    }
  }
);

/**
 * Get trending posts for discovery
 */
exports.getTrendingPosts = onCall(async (request) => {
  const { limit = 10, postType = 'all' } = request.data;

  try {
    // Get posts from the last 3 days with high engagement
    const threeDaysAgo = new Date();
    threeDaysAgo.setDate(threeDaysAgo.getDate() - 3);

    let postsQuery = firestore.collection('posts')
      .where('createdAt', '>', threeDaysAgo)
      .orderBy('createdAt', 'desc');

    // Apply post type filter if specified
    if (postType === 'public') {
      postsQuery = postsQuery.where('isAlt', '==', false);
    } else if (postType === 'alt') {
      postsQuery = postsQuery.where('isAlt', '==', true);
    }

    // Get more posts than needed to allow for sorting
    postsQuery = postsQuery.limit(limit * 3);

    const postsSnapshot = await postsQuery.get();

    if (postsSnapshot.empty) {
      return { posts: [] };
    }

    // Convert to array and ensure date objects are properly converted
    let posts = postsSnapshot.docs.map(doc => {
      const data = doc.data();

      // Important: Convert Firestore timestamp to Date
      let createdAt = data.createdAt;
      if (createdAt && typeof createdAt.toDate === 'function') {
        createdAt = createdAt.toDate();
      } else if (!(createdAt instanceof Date)) {
        createdAt = new Date(); // Default fallback
      }

      return {
        id: doc.id,
        ...data,
        createdAt: createdAt // Replace with properly converted date
      };
    });

    // Now sort using the properly converted dates
    posts = hotAlgorithm.sortPosts(posts, 0.5);

    // Return top posts
    return { posts: posts.slice(0, limit) };
  } catch (error) {
    logger.error('Error getting trending posts:', error);
    throw new HttpsError('internal', `Failed to get trending posts: ${error.message}`);
  }
});

// Debug function to find documents with NaN hotScores
exports.findNaNHotScores = onCall(async (request) => {
  if (!request.auth || !request.auth.token.admin) {
    throw new HttpsError('permission-denied', 'Admin only function');
  }

  try {
    const collections = ['posts', 'altPosts'];
    const problematicDocs = [];

    for (const collectionName of collections) {
      const snapshot = await firestore.collection(collectionName).get();

      snapshot.docs.forEach(doc => {
        const data = doc.data();
        if ('hotScore' in data && (isNaN(data.hotScore) || data.hotScore === undefined)) {
          problematicDocs.push({
            collection: collectionName,
            id: doc.id,
            hotScore: data.hotScore,
            data: {
              likeCount: data.likeCount,
              dislikeCount: data.dislikeCount,
              createdAt: data.createdAt ? 'valid date' : 'invalid date'
            }
          });
        }
      });
    }

    return { problematicDocs };
  } catch (error) {
    logger.error('Error finding NaN hotScores:', error);
    throw new HttpsError('internal', `Error: ${error.message}`);
  }
});