const { admin, firestore, db } = require('./admin_init');

const notificationFunctionsFactory = require('./notification_functions');
const notificationHandlers = notificationFunctionsFactory(admin);

// Import grouped functions
const callableHandlers = require('./callable_handlers');
const postTriggers = require('./post_triggers');
const scoreFunctions = require('./score_functions');
const userEventHandlers = require('./user_event_handlers');
const migrationFunctions = require('./migration_functions');
const dataExportFunctions = require('./data_export_functions');

const debugFunctions = require('./debug_functions');


const allFunctions = {
  ...callableHandlers,
  ...postTriggers,
  ...scoreFunctions,
  ...userEventHandlers,
  ...notificationHandlers,
  ...migrationFunctions,
  ...dataExportFunctions,
  ...debugFunctions,
};


for (const functionName in allFunctions) {
  if (Object.prototype.hasOwnProperty.call(allFunctions, functionName)) {
    exports[functionName] = allFunctions[functionName];
  }
}