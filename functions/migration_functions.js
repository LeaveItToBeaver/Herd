const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { logger } = require('firebase-functions');
const admin = require('firebase-admin');

/**
 * Migration function to update existing herds to use the new role-based system.
 *
 * This migrates from the old system where:
 * - creatorId field indicated the owner
 * - moderatorIds array indicated moderators
 * - isModerator boolean indicated moderator status
 *
 * To the new system where:
 * - Each herdMember has a 'role' field (owner, admin, moderator, member)
 * - Role hierarchy is enforced
 * - Permissions are derived from roles
 *
 * Usage: Call this function manually once to migrate all existing herds
 */
exports.migrateHerdRoles = onCall(
  {
    timeoutSeconds: 540,
    memory: '1GiB',
    enforceAppCheck: false,
  },
  async (request) => {
    // Only allow admins to run migrations (you can add your own auth check)
    if (!request.auth) {
      throw new HttpsError(
        'unauthenticated',
        'Must be authenticated to run migrations'
      );
    }

    const db = admin.firestore();
    const results = {
      herdsProcessed: 0,
      membersUpdated: 0,
      errors: [],
      alreadyMigrated: 0,
    };

    try {
      // Get all herds
      const herdsSnapshot = await db.collection('herds').get();
      logger.info(`Found ${herdsSnapshot.size} herds to process`);

      for (const herdDoc of herdsSnapshot.docs) {
        try {
          const herdId = herdDoc.id;
          const herdData = herdDoc.data();
          const creatorId = herdData.creatorId;
          const moderatorIds = herdData.moderatorIds || [];

          logger.info(`Processing herd: ${herdId} (${herdData.name})`);

          // Get all members of this herd
          const membersSnapshot = await db
            .collection('herdMembers')
            .doc(herdId)
            .collection('members')
            .get();

          logger.info(`  Found ${membersSnapshot.size} members`);

          // Process each member
          const batch = db.batch();
          let batchCount = 0;
          let memberUpdateCount = 0;

          for (const memberDoc of membersSnapshot.docs) {
            const memberId = memberDoc.id;
            const memberData = memberDoc.data();

            // Check if already migrated
            if (memberData.role) {
              results.alreadyMigrated++;
              logger.info(`  Member ${memberId} already has role: ${memberData.role}`);
              continue;
            }

            // Determine the role based on old system
            let role = 'member';
            if (memberId === creatorId) {
              role = 'owner';
            } else if (moderatorIds.includes(memberId)) {
              role = 'moderator';
            }

            // Update the member document with role
            batch.update(memberDoc.ref, {
              role: role,
              roleChangedAt: admin.firestore.FieldValue.serverTimestamp(),
              promotedBy: role === 'owner' ? 'system' : creatorId,
              // Preserve existing fields
              ...memberData,
            });

            memberUpdateCount++;
            batchCount++;

            // Commit batch every 500 writes (Firestore limit)
            if (batchCount >= 500) {
              await batch.commit();
              logger.info(`  Committed batch of ${batchCount} updates`);
              batchCount = 0;
            }
          }

          // Commit remaining updates
          if (batchCount > 0) {
            await batch.commit();
            logger.info(`  Committed final batch of ${batchCount} updates`);
          }

          results.herdsProcessed++;
          results.membersUpdated += memberUpdateCount;
          logger.info(`  Updated ${memberUpdateCount} members in herd ${herdId}`);
        } catch (error) {
          const errorMsg = `Error processing herd ${herdDoc.id}: ${error.message}`;
          logger.error(errorMsg);
          results.errors.push(errorMsg);
        }
      }

      logger.info('Migration complete:', results);
      return results;
    } catch (error) {
      logger.error('Migration failed:', error);
      throw new HttpsError('internal', error.message);
    }
  }
);

/**
 * Migrate a single herd's roles (useful for testing or incremental migration)
 */
exports.migrateSingleHerdRoles = onCall(
  {
    enforceAppCheck: false,
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Must be authenticated');
    }

    const { herdId } = request.data;
    if (!herdId) {
      throw new HttpsError('invalid-argument', 'herdId is required');
    }

    const db = admin.firestore();
    const results = {
      membersUpdated: 0,
      alreadyMigrated: 0,
      errors: [],
    };

    try {
      // Get the herd
      const herdDoc = await db.collection('herds').doc(herdId).get();
      if (!herdDoc.exists) {
        throw new HttpsError('not-found', 'Herd not found');
      }

      const herdData = herdDoc.data();
      const creatorId = herdData.creatorId;
      const moderatorIds = herdData.moderatorIds || [];

      // Get all members
      const membersSnapshot = await db
        .collection('herdMembers')
        .doc(herdId)
        .collection('members')
        .get();

      const batch = db.batch();
      let batchCount = 0;

      for (const memberDoc of membersSnapshot.docs) {
        const memberId = memberDoc.id;
        const memberData = memberDoc.data();

        // Check if already migrated
        if (memberData.role) {
          results.alreadyMigrated++;
          continue;
        }

        // Determine role
        let role = 'member';
        if (memberId === creatorId) {
          role = 'owner';
        } else if (moderatorIds.includes(memberId)) {
          role = 'moderator';
        }

        batch.update(memberDoc.ref, {
          role: role,
          roleChangedAt: admin.firestore.FieldValue.serverTimestamp(),
          promotedBy: role === 'owner' ? 'system' : creatorId,
        });

        results.membersUpdated++;
        batchCount++;

        if (batchCount >= 500) {
          await batch.commit();
          batchCount = 0;
        }
      }

      if (batchCount > 0) {
        await batch.commit();
      }

      return results;
    } catch (error) {
      logger.error('Single herd migration failed:', error);
      throw new HttpsError('internal', error.message);
    }
  }
);

/**
 * Check migration status for a herd
 */
exports.checkHerdMigrationStatus = onCall(
  {
    enforceAppCheck: false,
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Must be authenticated');
    }

    const { herdId } = request.data;
    if (!herdId) {
      throw new HttpsError('invalid-argument', 'herdId is required');
    }

    const db = admin.firestore();

    try {
      const membersSnapshot = await db
        .collection('herdMembers')
        .doc(herdId)
        .collection('members')
        .get();

      let totalMembers = 0;
      let migratedMembers = 0;
      const roleDistribution = {
        owner: 0,
        admin: 0,
        moderator: 0,
        member: 0,
        unmigrated: 0,
      };

      membersSnapshot.forEach((doc) => {
        totalMembers++;
        const data = doc.data();

        if (data.role) {
          migratedMembers++;
          roleDistribution[data.role] = (roleDistribution[data.role] || 0) + 1;
        } else {
          roleDistribution.unmigrated++;
        }
      });

      return {
        herdId,
        totalMembers,
        migratedMembers,
        unmigrated: totalMembers - migratedMembers,
        percentageMigrated:
          totalMembers > 0
            ? Math.round((migratedMembers / totalMembers) * 100)
            : 0,
        roleDistribution,
        fullyMigrated: migratedMembers === totalMembers,
      };
    } catch (error) {
      logger.error('Check migration status failed:', error);
      throw new HttpsError('internal', error.message);
    }
  }
);

module.exports = {
  migrateHerdRoles: exports.migrateHerdRoles,
  migrateSingleHerdRoles: exports.migrateSingleHerdRoles,
  checkHerdMigrationStatus: exports.checkHerdMigrationStatus,
};
