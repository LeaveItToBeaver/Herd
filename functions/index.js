const functions = require('firebase-functions');
const { onDocumentCreated, onDocumentDeleted, onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { logger } = require("firebase-functions");
const { getFirestore } = require('firebase-admin/firestore');
const { admin, firestore, db } = require('./admin_init');

const admin = require("firebase-admin");

admin.initializeApp();
const notificationFunctionsFactory = require('./notification_functions');
const notificationFunctions = notificationFunctionsFactory(admin);

// Import grouped functions
const callableHandlers = require('./callable_handlers');
const postTriggers = require('./post_triggers');
const scoreFunctions = require('./score_functions');
const userEventHandlers = require('./user_event_handlers');

// Notification functions (using the factory pattern you established)
const notificationFunctionsFactory = require('./notification_functions');
const notificationHandlers = notificationFunctionsFactory(admin); // Pass admin instance


const allFunctions = {
  ...callableHandlers,
  ...postTriggers,
  ...scoreFunctions,
  ...userEventHandlers,
  ...notificationHandlers,
};


for (const functionName in allFunctions) {
  if (Object.prototype.hasOwnProperty.call(allFunctions, functionName)) {
    exports[functionName] = allFunctions[functionName];
  }
}


exports.onNewFollower = notificationFunctions.onNewFollower;
exports.onNewPost = notificationFunctions.onNewPost;
exports.onPostLike = notificationFunctions.onPostLike;
exports.onNewComment = notificationFunctions.onNewComment;
exports.onConnectionRequest = notificationFunctions.onConnectionRequest;
exports.onConnectionAccepted = notificationFunctions.onConnectionAccepted;
exports.markNotificationsAsRead = notificationFunctions.markNotificationsAsRead;
exports.deleteNotifications = notificationFunctions.deleteNotifications;
