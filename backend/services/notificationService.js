const admin = require('firebase-admin');
const Notification = require('../models/NotificationSchema');

// Initialize Firebase Admin SDK
// Note: You'll need to add your Firebase service account key file
admin.initializeApp({
    credential: admin.credential.applicationDefault(),
    // Add your Firebase project configuration here
});

const notificationService = {
    async sendNotification(userId, title, message, data = {}) {
        try {
            // Create notification in database
            const notification = new Notification({
                recipient: userId,
                type: data.type || 'GENERAL',
                title,
                message,
                data
            });
            await notification.save();

            // Get user's FCM token (you'll need to add this to your UserSchema)
            const user = await User.findById(userId);
            if (!user || !user.fcmToken) {
                console.log('User not found or FCM token not available');
                return;
            }

            // Send FCM notification
            const message = {
                notification: {
                    title,
                    body: message
                },
                data: {
                    ...data,
                    notificationId: notification._id.toString()
                },
                token: user.fcmToken
            };

            const response = await admin.messaging().send(message);
            console.log('Successfully sent notification:', response);
            return notification;
        } catch (error) {
            console.error('Error sending notification:', error);
            throw error;
        }
    },

    async getNotifications(userId) {
        return await Notification.find({ recipient: userId })
            .sort({ created_at: -1 });
    },

    async markAsRead(notificationId) {
        return await Notification.findByIdAndUpdate(
            notificationId,
            { read: true },
            { new: true }
        );
    }
};

module.exports = notificationService;
