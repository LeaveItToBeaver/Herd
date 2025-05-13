const { logger } = require("firebase-functions");
const admin = require("firebase-admin");


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

module.exports = {
    hotAlgorithm,
    sanitizeData,
    findPostMediaItems
};