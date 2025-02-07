const admin = require('firebase-admin');
const Notification = require('../models/NotificationSchema');
const User = require('../models/UserSchema'); // Ensure you import User schema

// Check if Firebase is already initialized
if (!admin.apps.length) {
    admin.initializeApp({
        credential: admin.credential.applicationDefault(),
        // Add other Firebase configurations if needed
    });
}

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

            // Get user's FCM token
            const user = await User.findById(userId);
            if (!user || !user.fcmToken) {
                console.log('User not found or FCM token not available');
                return;
            }

            // Prepare FCM notification
            const fcmMessage = {
                notification: { title, body: message },
                data: { ...data, notificationId: notification._id.toString() },
                token: user.fcmToken
            };

            // Send notification
            const response = await admin.messaging().send(fcmMessage);
            console.log('Successfully sent notification:', response);
            return notification;
        } catch (error) {
            console.error('Error sending notification:', error);
            throw error;
        }
    },

    async getNotifications(userId) {
        return await Notification.find({ recipient: userId })
            .sort({ createdAt: -1 }); // Ensure the field name matches your schema
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
