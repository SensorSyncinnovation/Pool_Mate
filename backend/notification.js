const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
const serviceAccount = require('./service.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const message = {
  notification: {
    title: 'Hello!',
    body: 'This is a test notification.',
  },
  token: 'fQWFHMD2RQ2lciaJHu-VZ5:APA91bH4t3I9N9TXOWYPB7VnWxvnC4qreUW9zG136SgBG90QvjHFL_xRCFifJ_3_xj3U47ZlATrz7rUEgG5sCmYMW98AR512_R19tOVZe-QimaqWizD9q-E', // Your FCM Token
};

admin.messaging().send(message)
  .then((response) => {
    console.log('Successfully sent message:', response);
  })
  .catch((error) => {
    console.error('Error sending message:', error);
  });
