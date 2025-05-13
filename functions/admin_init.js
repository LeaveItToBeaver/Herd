const admin = require("firebase-admin");
admin.initializeApp();
const firestore = admin.firestore();
const db = require('firebase-admin/firestore').getFirestore();

module.exports = { admin, firestore, db };