const admin = require('firebase-admin');
const serviceAccount = require('./service.json'); // Replace with your service account file

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

module.exports = admin;
