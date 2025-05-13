const functions = require('firebase-functions');
const { onDocumentCreated, onDocumentDeleted, onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { logger } = require("firebase-functions");
const { getFirestore } = require('firebase-admin/firestore');
const admin = require("firebase-admin");


admin.initializeApp();
const firestore = admin.firestore();
const db = getFirestore();

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
      const timeDecay = Math.pow(timeSinceCreation, -0.7) * sanitizedDecayFactor;

      // Calculate hours since creation
      const hoursOld = timeSinceCreation / 3600;

      // Apply new boost factor for fresh posts (first 12 hours)
      const newBoostFactor =
        hoursOld <= 1 ? 5.0 :   // First hour: 5x boost
          hoursOld <= 3 ? 4.0 :   // Hours 1-3: 4x boost
            hoursOld <= 6 ? 3.0 :   // Hours 3-6: 3x boost
              hoursOld <= 12 ? 2.0 :  // Hours 6-12: 2x boost
                1.0;

      // Apply age penalty for posts older than 24 hours
      const agePenalty = hoursOld > 12 ? Math.pow(12 / hoursOld, 2.0) : 1.0;

      // Calculate final score with new factors
      const score = sign * magnitude * timeDecay * newBoostFactor * agePenalty;

      if (hoursOld > 72) {
        return 0; // Zero score for posts older than 3 days
      }
      // Debug logging (before return)
      logger.info(`Hot score calculation: netVotes=${sanitizedNetVotes},
        timeDecay=${timeDecay},
        hoursOld=${hoursOld.toFixed(2)},
        newBoostFactor=${newBoostFactor},
        agePenalty=${agePenalty.toFixed(4)},
        score=${score}`);

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
    // Check if this is a posts array (contain feedType property)
    if (obj.length > 0 && obj[0] && typeof obj[0] === 'object' && obj[0].feedType) {
      // This is a posts array - don't filter, just sanitize each
      return obj.map(item => sanitizeData(item));
    }

    // Check if this is a mediaItems array
    if (obj.length > 0 && obj[0] && typeof obj[0] === 'object' &&
      (obj[0].url || obj[0].thumbnailUrl) && obj[0].mediaType) {
      // This is a mediaItems array - filter out items without URLs
      return obj.filter(item => item && (item.url || item.thumbnailUrl))
        .map(item => sanitizeData(item));
    }

    // For any other array, just sanitize each item
    return obj.map(item => sanitizeData(item));
  }

  // Handle objects - same as before
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
        const [metadata] = await file.getMetadata();
        const token = metadata.metadata.firebaseStorageDownloadTokens;
        const bucket = admin.storage().bucket().name;
        const pathEncoded = encodeURIComponent(file.name);
        mediaGroups[mediaId].url =
          `https://firebasestorage.googleapis.com/v0/b/${bucket}/o/${pathEncoded}` +
          `?alt=media&token=${token}`;

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
        const [metadata] = await file.getMetadata();
        const token = metadata.metadata.firebaseStorageDownloadTokens;
        const bucket = admin.storage().bucket().name;
        const pathEncoded = encodeURIComponent(file.name);
        mediaGroups[mediaId].thumbnailUrl =
          `https://firebasestorage.googleapis.com/v0/b/${bucket}/o/${pathEncoded}` +
          `?alt=media&token=${token}`;
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

/**
 * Helper function to update hot scores in user feeds
 * @param {Array} updatedPosts - Array of objects containing post info
 */
async function updateUserFeedsForPosts(updatedPosts) {
  if (updatedPosts.length === 0) return;

  const MAX_BATCH_SIZE = 500;
  let batch = firestore.batch();
  let operationCount = 0;

  for (const post of updatedPosts) {
    // Find all user feeds containing this post
    let userFeedsQuery = firestore
      .collectionGroup("feed")
      .where("id", "==", post.id)
      .where("sourceCollection", "==", post.sourceCollection);

    // Add herdId filter if applicable
    if (post.sourceCollection === 'herdPosts' && post.herdId) {
      userFeedsQuery = userFeedsQuery.where("herdId", "==", post.herdId);
    }

    const feedEntries = await userFeedsQuery.select().get();

    if (feedEntries.empty) {
      logger.info(`No user feed entries found for ${post.sourceCollection} ${post.id}`);
      continue;
    }

    logger.info(`Updating hot score for ${post.sourceCollection} ${post.id} in ${feedEntries.size} user feeds`);

    for (const doc of feedEntries.docs) {
      batch.update(doc.ref, { hotScore: post.hotScore });
      operationCount++;

      if (operationCount >= MAX_BATCH_SIZE) {
        await batch.commit();
        batch = firestore.batch();
        operationCount = 0;
      }
    }
  }

  if (operationCount > 0) {
    await batch.commit();
  }

  logger.info(`User feeds updated with new hot scores for ${updatedPosts.length} posts`);
}

[
  { path: "posts/{postId}", sourceCollection: "posts" },
  { path: "altPosts/{postId}", sourceCollection: "altPosts" },
  { path: "herdPosts/{herdId}/posts/{postId}", sourceCollection: "herdPosts" }
].forEach(({ path, sourceCollection }) => {
  exports[`syncHotScore_${sourceCollection}`] = onDocumentUpdated(
    path,
    async (event) => {
      const postId = event.params.postId;
      const after = event.data.after.data();
      const newHotScore = after.hotScore;
      logger.info(`Syncing hotScore=${newHotScore} for ${sourceCollection}/${postId}`);

      // Find and update all feed entries
      const feeds = await admin
        .firestore()
        .collectionGroup("feed")
        .where("id", "==", postId)
        .where("sourceCollection", "==", sourceCollection)
        .get();

      if (feeds.empty) {
        logger.info(`No feed docs found for ${postId} in ${sourceCollection}`);
        return;
      }

      const batch = admin.firestore().batch();
      feeds.forEach(doc => {
        batch.update(doc.ref, { hotScore: newHotScore });
      });
      await batch.commit();
      logger.info(`Updated ${feeds.size} feed docs for ${postId}`);
    }
  );
});


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
 * Handle post interactions (likes/dislikes) with the unified feed approach
 */
exports.handlePostInteraction = onCall({
  enforceAppCheck: false,
},
  async (request) => {
    const {
      postId,
      interactionType,
      feedType,
      herdId
    } = request.data;

    // Validate authentication
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'User must be logged in');
    }

    if (feedType === 'herd' && !herdId) {
      throw new HttpsError('invalid-argument', 'herdId is required for herd posts');
    }


    const userId = request.auth.uid;

    let postRef;

    // If it's a herd post, we need to first find out where the full data is stored
    if (feedType === 'herd') {
      // First get the reference data from herdPosts
      const herdPostRefDoc = await firestore
        .collection('herdPosts')
        .doc(herdId)
        .collection('posts')
        .doc(postId)
        .get();

      if (!herdPostRefDoc.exists) {
        throw new HttpsError('not-found', 'Post reference not found');
      }

      // Extract the source collection from the reference data
      const sourceCollection = herdPostRefDoc.data().sourceCollection || 'altPosts';

      // Set reference to the actual full post data
      postRef = firestore.collection(sourceCollection).doc(postId);
    }
    else if (feedType === 'public') {
      postRef = firestore.collection('posts').doc(postId);
    }
    else if (feedType === 'alt') {
      postRef = firestore.collection('altPosts').doc(postId);
    }
    else {
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

      logger.info(`Updated hot score for post ${postId}: ${updatedHotScore}`);

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
    limit = 15,
    lastHotScore = null,
    lastPostId = null
  } = request.data;

  // Validate required userId
  const userId = request.data.userId;

  // Add detailed logging
  logger.info(`getFeed called with params: ${JSON.stringify({
    userId, feedType, herdId, limit, lastHotScore, lastPostId
  })}`);

  if (!userId) {
    logger.error('getFeed called without userId');
    throw new HttpsError('invalid-argument', 'User ID is required');
  }

  try {
    // Different query strategy based on feed type
    let postsResult = {};

    if (feedType === 'public') {
      logger.info(`Getting public feed for user: ${userId}`);
      postsResult = await getPublicFeed(userId, limit, lastHotScore, lastPostId);
      logger.info(`hasMorePosts: ${postsResult.hasMorePosts}`);
    }
    else if (feedType === 'alt') {
      logger.info(`Getting alt feed, lastHotScore: ${lastHotScore}, lastPostId: ${lastPostId}, for user: ${userId}`);
      postsResult = await getAltFeed(limit, lastHotScore, lastPostId);
      logger.info(`hasMorePosts: ${postsResult.hasMorePosts}`);
    }
    else if (herdId) {
      logger.info(`Getting herd feed for herd: ${herdId}`);
      postsResult = await getHerdFeed(herdId, limit, lastHotScore, lastPostId);
      logger.info(`hasMorePosts: ${postsResult.hasMorePosts}`);
    } else {
      logger.info(`Defaulting to public feed for user: ${userId}`);
      postsResult = await getPublicFeed(userId, limit, lastHotScore, lastPostId);
      logger.info(`hasMorePosts: ${postsResult.hasMorePosts}`);
    }

    logger.info(`Feed query returned ${postsResult.posts?.length || 0} posts`);

    // Log the first post to verify structure
    if (postsResult.posts && postsResult.posts.length > 0) {
      logger.info(`Sample post: ${JSON.stringify({
        id: postsResult.posts[0].id,
        hotScore: postsResult.posts[0].hotScore,
        feedType: postsResult.posts[0].feedType
      })}`);
    }

    // Deep sanitize the entire response to remove any NaN values
    const sanitizedResult = sanitizeData({
      posts: postsResult.posts,
      lastHotScore: postsResult.lastHotScore,
      lastPostId: postsResult.lastPostId,
      hasMorePosts: postsResult.hasMorePosts
    });

    return sanitizedResult;
  } catch (error) {
    logger.error(`Error getting feed for user ${userId}:`, error);
    throw new HttpsError('internal', `Failed to get feed: ${error.message}`);
  }
});

// Get public feed (personalized for each user)
async function getPublicFeed(userId, limit, lastHotScore, lastPostId) {
  try {
    // STEP 1: Query the userFeeds to get the ordered post IDs
    let feedQuery = firestore
      .collection('userFeeds')
      .doc(userId)
      .collection('feed')
      .where('feedType', '==', 'public')
      .orderBy('hotScore', 'desc')
      .orderBy(admin.firestore.FieldPath.documentId(), 'asc');

    // Apply pagination
    if (lastHotScore !== null && lastPostId !== null) {
      logger.info(`Attempting to paginate public feed with lastHotScore: ${lastHotScore}, lastPostId: ${lastPostId}`);
      // Use startAfter with an array of values to match the orderBy fields
      feedQuery = feedQuery.startAfter(lastHotScore, lastPostId);
    }

    // Apply limit
    feedQuery = feedQuery.limit(limit);

    // Execute query to get feed entries
    const feedSnapshot = await feedQuery.get();

    if (feedSnapshot.empty) {
      logger.info(`No public feed entries found for user: ${userId}`);
      return { posts: [], lastHotScore: null, lastPostId: null };
    }

    // Extract post IDs and hot scores from feed entries
    const postIds = [];
    const hotScoreMap = {};

    feedSnapshot.docs.forEach(doc => {
      postIds.push(doc.id);
      const data = doc.data();
      hotScoreMap[doc.id] = data.hotScore || 0;
    });

    logger.info(`Found ${postIds.length} public feed entries for user: ${userId}`);

    // STEP 2: Query the source of truth for complete post data
    // Split into chunks of 10 for whereIn query limitation
    const chunkedResults = [];

    for (let i = 0; i < postIds.length; i += 10) {
      const chunk = postIds.slice(i, i + 10);

      const postsQuery = firestore
        .collection('posts')
        .where(admin.firestore.FieldPath.documentId(), 'in', chunk);

      const postsSnapshot = await postsQuery.get();

      postsSnapshot.docs.forEach(doc => {
        chunkedResults.push({
          id: doc.id,
          ...doc.data(),
          // Use hot score from user feed to maintain ordering
          hotScore: hotScoreMap[doc.id]
        });
      });
    }


    const posts = chunkedResults.sort((a, b) => b.hotScore - a.hotScore);

    const userInteractions = await getUserInteractionsForPosts(userId, posts.map(post => post.id));

    // Add user-specific data to each post
    const enrichedPosts = posts.map(post => {
      return {
        ...post,
        isLiked: userInteractions[post.id]?.isLiked || false,
        isDisliked: userInteractions[post.id]?.isDisliked || false
      };
    });

    logger.info(`Retrieved ${posts.length} complete posts for public feed`);

    // Return the results with pagination info
    return {
      posts: enrichedPosts,
      lastHotScore: posts.length > 0 ? posts[posts.length - 1].hotScore : null,
      lastPostId: posts.length > 0 ? posts[posts.length - 1].id : null,
      hasMorePosts: posts.length >= limit
    };
  } catch (error) {
    logger.error(`Error getting public feed: ${error}`);
    throw error;
  }
}

// Get alt feed (global, like Reddit's r/All)
async function getAltFeed(limit, lastHotScore, lastPostId) {
  try {
    // Query the global alt posts collection
    let feedQuery = firestore
      .collection('altPosts')
      .orderBy('hotScore', 'desc')
      .orderBy(admin.firestore.FieldPath.documentId(), 'asc');

    // Apply pagination
    if (lastHotScore !== null && lastPostId !== null) {
      logger.info(`Attempting to paginate alt feed with lastHotScore: ${lastHotScore}, lastPostId: ${lastPostId}`);
      // Use startAfter with an array of values to match the orderBy fields 
      feedQuery = feedQuery.startAt(lastHotScore, lastPostId);
    }

    // Apply limit
    feedQuery = feedQuery.limit(limit);

    // Execute query to get complete alt posts
    const snapshot = await feedQuery.get();

    if (snapshot.empty) {
      logger.info('No alt posts found');
      return { posts: [], lastHotScore: null, lastPostId: null };
    }

    const posts = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));

    logger.info(`Retrieved ${posts.length} alt posts`);

    return {
      posts,
      lastHotScore: posts.length > 0 ? posts[posts.length - 1].hotScore : null,
      lastPostId: posts.length > 0 ? posts[posts.length - 1].id : null,
      hasMorePosts: posts.length >= limit
    };
  } catch (error) {
    logger.error(`Error getting alt feed: ${error}`);
    throw error;
  }
}

// Get herd-specific feed
async function getHerdFeed(herdId, limit, lastHotScore, lastPostId) {
  let feedQuery = firestore
    .collection('herdPosts')
    .doc(herdId)
    .collection('posts')
    .orderBy('hotScore', 'desc')
    .orderBy(admin.firestore.FieldPath.documentId(), 'asc');

  // Apply pagination
  if (lastHotScore !== null && lastPostId !== null) {
    feedQuery = feedQuery.startAt(lastHotScore, lastPostId);
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
    lastPostId: posts.length > 0 ? posts[posts.length - 1].id : null,
    hasMorePosts: posts.length >= limit
  };
}

async function getUserInteractionsForPosts(userId, postIds) {
  // Batch get user interactions for all posts
  const interactionsRef = firestore.collection('userInteractions').doc(userId);
  const interactionsSnapshot = await interactionsRef.get();

  if (!interactionsSnapshot.exists) {
    return {};
  }

  const interactions = interactionsSnapshot.data() || {};
  const result = {};

  // Filter to just the posts we care about
  postIds.forEach(postId => {
    if (interactions[postId]) {
      result[postId] = interactions[postId];
    }
  });

  return result;
}

/**
 * Update user feed when a follow/unfollow action occurs
 */
exports.handleFollowAction = onDocumentCreated(
  "followers/{followedId}/userFollowers/{followerId}",
  async (event) => {
    const followedId = event.params.followedId;
    const followerId = event.params.followerId;

    try {
      logger.info(`Follow action: ${followerId} is now following ${followedId}`);

      // Query all public posts from the followed user (not just recent ones)
      const postsQuery = firestore
        .collection('posts')
        .where('authorId', '==', followedId)
        .where('isAlt', '==', false) // Only public posts
        .orderBy('createdAt', 'desc')
        .limit(50); // Increased from 20 to get more historical posts

      const postsSnapshot = await postsQuery.get();

      if (postsSnapshot.empty) {
        logger.info(`No public posts found for user ${followedId}`);
        return null;
      }

      logger.info(`Found ${postsSnapshot.size} posts from ${followedId} to add to ${followerId}'s feed`);

      // Batch add posts to follower's feed
      const batch = firestore.batch();

      for (const doc of postsSnapshot.docs) {
        const postData = doc.data();
        const postId = doc.id;

        // Calculate hotScore if it doesn't exist
        const hotScore = postData.hotScore || hotAlgorithm.calculateHotScore(
          (postData.likeCount || 0) - (postData.dislikeCount || 0),
          postData.createdAt.toDate()
        );

        // Create minimal version of post data for the feed
        const feedPostData = {
          id: postId,
          authorId: postData.authorId,
          authorName: postData.authorName || null,
          authorUsername: postData.authorUsername || null,
          authorProfileImageURL: postData.authorProfileImageURL || null,
          content: postData.content,
          createdAt: postData.createdAt,
          likeCount: postData.likeCount || 0,
          dislikeCount: postData.dislikeCount || 0,
          commentCount: postData.commentCount || 0,
          feedType: 'public',
          hotScore: hotScore,
          mediaItems: postData.mediaItems || [],
          sourceCollection: 'posts'
        };

        const feedRef = firestore
          .collection('userFeeds')
          .doc(followerId)
          .collection('feed')
          .doc(postId);

        batch.set(feedRef, feedPostData);
      }

      await batch.commit();
      logger.info(`Successfully added ${postsSnapshot.size} posts to feed of user ${followerId}`);
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

// Add this function to your index.js file
exports.retroactivelyFillUserFeeds = onCall({
  enforceAppCheck: false,
  timeoutSeconds: 540, // 9 minutes, close to the max timeout
}, async (request) => {
  // Admin-only check (you should implement proper admin verification)
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Authentication required');
  }

  const callerUid = request.auth.uid;

  // Verify admin status (implement this based on your admin structure)
  const adminDoc = await firestore.collection('admins').doc(callerUid).get();
  if (!adminDoc.exists) {
    throw new HttpsError('permission-denied', 'Admin access required');
  }

  const { batchSize = 50, startAfterUid = null } = request.data;

  try {
    // Setup query to get users in batches
    let usersQuery = firestore.collection('users');

    // Optional pagination
    if (startAfterUid) {
      const startAfterDoc = await firestore.collection('users').doc(startAfterUid).get();
      if (startAfterDoc.exists) {
        usersQuery = usersQuery.startAfter(startAfterDoc);
      }
    }

    // Get batch of users
    const usersSnapshot = await usersQuery.limit(batchSize).get();

    if (usersSnapshot.empty) {
      return {
        success: true,
        message: 'No users found to process',
        processedCount: 0,
        lastProcessedUid: null,
        complete: true
      };
    }

    logger.info(`Processing ${usersSnapshot.size} users for feed backfill`);

    let processedCount = 0;
    let lastProcessedUid = null;

    // Process each user
    for (const userDoc of usersSnapshot.docs) {
      const userId = userDoc.id;
      lastProcessedUid = userId;

      // Get users this person is following
      const followingSnapshot = await firestore
        .collection('following')
        .doc(userId)
        .collection('userFollowing')
        .get();

      if (followingSnapshot.empty) {
        logger.info(`User ${userId} is not following anyone, skipping`);
        processedCount++;
        continue;
      }

      // Get existing feed entries to avoid duplicates
      const existingFeedSnapshot = await firestore
        .collection('userFeeds')
        .doc(userId)
        .collection('feed')
        .get();

      // Create a Set of existing post IDs for fast lookup
      const existingPostIds = new Set();
      existingFeedSnapshot.forEach(doc => existingPostIds.add(doc.id));

      // Process each followed user
      for (const followingDoc of followingSnapshot.docs) {
        const followedUserId = followingDoc.id;

        // Get posts from followed user that aren't already in the feed
        const postsSnapshot = await firestore
          .collection('posts')
          .where('authorId', '==', followedUserId)
          .where('isAlt', '==', false)
          .orderBy('createdAt', 'desc')
          .limit(100)
          .get();

        if (postsSnapshot.empty) {
          continue;
        }

        // Prepare batch write
        const batch = firestore.batch();
        let addedCount = 0;

        for (const postDoc of postsSnapshot.docs) {
          const postId = postDoc.id;
          const postData = postDoc.data();

          // Skip if already in feed
          if (existingPostIds.has(postId)) {
            continue;
          }

          // Calculate hot score
          const netVotes = (postData.likeCount || 0) - (postData.dislikeCount || 0);
          const hotScore = hotAlgorithm.calculateHotScore(
            netVotes,
            postData.createdAt?.toDate() || new Date()
          );

          // Create feed entry
          const feedRef = firestore
            .collection('userFeeds')
            .doc(userId)
            .collection('feed')
            .doc(postId);

          batch.set(feedRef, {
            id: postId,
            authorId: postData.authorId,
            authorName: postData.authorName || null,
            authorUsername: postData.authorUsername || null,
            authorProfileImageURL: postData.authorProfileImageURL || null,
            content: postData.content || '',
            createdAt: postData.createdAt,
            feedType: 'public',
            hotScore: hotScore,
            likeCount: postData.likeCount || 0,
            dislikeCount: postData.dislikeCount || 0,
            commentCount: postData.commentCount || 0,
            mediaItems: postData.mediaItems || [],
            sourceCollection: 'posts'
          });

          addedCount++;
          existingPostIds.add(postId); // Mark as processed

          // Commit in batches of 500 (Firestore limit)
          if (addedCount % 500 === 0) {
            await batch.commit();
            logger.info(`Committed batch of 500 posts for user ${userId}`);
            batch = firestore.batch(); // Create a new batch
          }
        }

        // Commit any remaining operations
        if (addedCount % 500 !== 0) {
          await batch.commit();
        }

        logger.info(`Added ${addedCount} posts from ${followedUserId} to ${userId}'s feed`);
      }

      processedCount++;
      logger.info(`Completed processing user ${userId} (${processedCount} of ${usersSnapshot.size})`);
    }

    const isComplete = usersSnapshot.size < batchSize;

    return {
      success: true,
      processedCount,
      lastProcessedUid,
      complete: isComplete,
      message: isComplete
        ? 'All users processed successfully'
        : 'Batch completed, more users remain'
    };

  } catch (error) {
    logger.error(`Error in retroactivelyFillUserFeeds:`, error);
    throw new HttpsError('internal', error.message);
  }
});

exports.fillUserFeedOnFollow = onCall({
  enforceAppCheck: true,
  timeoutSeconds: 120, // 2 minutes should be enough for single user
}, async (request) => {
  // Authentication check
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Authentication required');
  }

  const userId = request.auth.uid;
  const { followedUserId } = request.data;

  if (!followedUserId) {
    throw new HttpsError('invalid-argument', 'followedUserId is required');
  }

  try {
    logger.info(`Filling ${userId}'s feed with posts from ${followedUserId}`);

    // Get existing feed entries to avoid duplicates
    const existingFeedSnapshot = await firestore
      .collection('userFeeds')
      .doc(userId)
      .collection('feed')
      .get();

    // Create a Set of existing post IDs for fast lookup
    const existingPostIds = new Set();
    existingFeedSnapshot.forEach(doc => existingPostIds.add(doc.id));

    // Get posts from followed user
    const postsSnapshot = await firestore
      .collection('posts')
      .where('authorId', '==', followedUserId)
      .where('isAlt', '==', false)
      .orderBy('createdAt', 'desc')
      .limit(100)
      .get();

    if (postsSnapshot.empty) {
      return { success: true, addedCount: 0, message: 'No posts to add' };
    }

    // Prepare batch write
    const batch = firestore.batch();
    let addedCount = 0;

    for (const postDoc of postsSnapshot.docs) {
      const postId = postDoc.id;
      const postData = postDoc.data();

      // Skip if already in feed
      if (existingPostIds.has(postId)) {
        continue;
      }

      // Calculate hot score
      const netVotes = (postData.likeCount || 0) - (postData.dislikeCount || 0);
      const hotScore = hotAlgorithm.calculateHotScore(
        netVotes,
        postData.createdAt?.toDate() || new Date()
      );

      // Create feed entry
      const feedRef = firestore
        .collection('userFeeds')
        .doc(userId)
        .collection('feed')
        .doc(postId);

      batch.set(feedRef, {
        id: postId,
        authorId: postData.authorId,
        authorName: postData.authorName || null,
        authorUsername: postData.authorUsername || null,
        authorProfileImageURL: postData.authorProfileImageURL || null,
        content: postData.content || '',
        createdAt: postData.createdAt,
        feedType: 'public',
        hotScore: hotScore,
        likeCount: postData.likeCount || 0,
        dislikeCount: postData.dislikeCount || 0,
        commentCount: postData.commentCount || 0,
        mediaItems: postData.mediaItems || [],
        sourceCollection: 'posts'
      });

      addedCount++;

      // Commit in batches of 500 (Firestore limit)
      if (addedCount % 500 === 0) {
        await batch.commit();
        logger.info(`Committed batch of 500 posts for user ${userId}`);
        batch = firestore.batch(); // Create a new batch
      }
    }

    // Commit any remaining operations
    if (addedCount % 500 !== 0) {
      await batch.commit();
    }

    logger.info(`Added ${addedCount} posts from ${followedUserId} to ${userId}'s feed`);

    return {
      success: true,
      addedCount,
      message: `Added ${addedCount} posts to feed`
    };
  } catch (error) {
    logger.error(`Error in fillUserFeedOnFollow:`, error);
    throw new HttpsError('internal', error.message);
  }
});

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

exports.catchAndLogExceptions = onCall(async (request) => {
  try {
    const {
      errorMessage,
      stackTrace,
      errorCode,
      userId,
      route,
      action,
      appInfo
    } = request.data;

    if (!errorMessage) {
      throw new HttpsError("invalid-argument", 'Error Message is required');
    }

    const errorDoc = {
      errorMessage,
      stackTrace: stackTrace || 'No stack trace provided',
      errorCode: errorCode || 'No error code provided',
      userId: userId || 'No userId provided',
      route: route || 'No route provided',
      action: action || 'No action provided',
      appInfo: appInfo || 'No appInfo provided',
      timeStamp: admin.firestore.FieldValue.serverTimestamp(),
      authContext: request.auth ? {
        uid: request.data.uid,
        email: request.auth.token.email,
        emailVerified: request.auth.token.email_verified,
      } : null,
    };

    logger.error(`App Exception: ${errorMessage}`, {
      stackTrace,
      errorCode,
      userId,
      route,
      action
    });

    const docRef = await firestore
      .collection("appExceptions")
      .add(errorDoc);

  } catch (error) {
    logger.error(`Error in exception logging function`, error);
    throw new HttpsError('internal', `failed to log exception ${error.message}`);
  }
});
