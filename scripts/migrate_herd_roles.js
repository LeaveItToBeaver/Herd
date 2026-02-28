#!/usr/bin/env node
/**
 * Migration Script: Backfill 'role' field for all herd members
 * 
 * This script:
 * 1. Sets role='owner' for herd creators
 * 2. Sets role='moderator' for members with isModerator=true
 * 3. Sets role='member' for everyone else
 * 
 * Run with: node scripts/migrate_herd_roles.js
 * 
 * IMPORTANT: Run this in a test environment first!
 */

const admin = require('firebase-admin');

// Initialize Firebase Admin (uses default credentials from gcloud or service account)
admin.initializeApp({
  projectId: 'herdapp-54e26',
});

const db = admin.firestore();

async function migrateHerdRoles() {
  console.log('Starting herd role migration...\n');

  const stats = {
    herdsProcessed: 0,
    ownersSet: 0,
    moderatorsSet: 0,
    membersSet: 0,
    alreadyHasRole: 0,
    errors: 0,
  };

  try {
    // Get all herds
    const herdsSnapshot = await db.collection('herds').get();
    console.log(`Found ${herdsSnapshot.size} herds to process\n`);

    for (const herdDoc of herdsSnapshot.docs) {
      const herdId = herdDoc.id;
      const herdData = herdDoc.data();
      const creatorId = herdData.creatorId;
      const moderatorIds = herdData.moderatorIds || [];

      console.log(`Processing herd: ${herdData.name || herdId}`);
      console.log(`  Creator: ${creatorId}`);
      console.log(`  Legacy moderatorIds: ${moderatorIds.length}`);

      // Get all members of this herd
      const membersSnapshot = await db
        .collection('herdMembers')
        .doc(herdId)
        .collection('members')
        .get();

      console.log(`  Members: ${membersSnapshot.size}`);

      const batch = db.batch();
      let batchCount = 0;

      for (const memberDoc of membersSnapshot.docs) {
        const userId = memberDoc.id;
        const memberData = memberDoc.data();
        const memberRef = memberDoc.ref;

        // Skip if already has role field
        if (memberData.role) {
          stats.alreadyHasRole++;
          continue;
        }

        let newRole;
        let reason;

        if (userId === creatorId) {
          newRole = 'owner';
          reason = 'is creator';
          stats.ownersSet++;
        } else if (memberData.isModerator === true || moderatorIds.includes(userId)) {
          newRole = 'moderator';
          reason = memberData.isModerator ? 'has isModerator=true' : 'in moderatorIds array';
          stats.moderatorsSet++;
        } else {
          newRole = 'member';
          reason = 'default';
          stats.membersSet++;
        }

        console.log(`    ${userId.substring(0, 8)}... → ${newRole} (${reason})`);

        batch.update(memberRef, {
          role: newRole,
          roleChangedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        batchCount++;

        // Firestore batches are limited to 500 operations
        if (batchCount >= 450) {
          await batch.commit();
          console.log(`    Committed batch of ${batchCount} updates`);
          batchCount = 0;
        }
      }

      // Commit remaining updates
      if (batchCount > 0) {
        await batch.commit();
        console.log(`    Committed batch of ${batchCount} updates`);
      }

      stats.herdsProcessed++;
      console.log('');
    }

    console.log('\n=== Migration Complete ===');
    console.log(`Herds processed: ${stats.herdsProcessed}`);
    console.log(`Owners set: ${stats.ownersSet}`);
    console.log(`Moderators set: ${stats.moderatorsSet}`);
    console.log(`Members set: ${stats.membersSet}`);
    console.log(`Already had role: ${stats.alreadyHasRole}`);
    console.log(`Errors: ${stats.errors}`);

  } catch (error) {
    console.error('Migration failed:', error);
    process.exit(1);
  }
}

// Run migration
migrateHerdRoles()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });
