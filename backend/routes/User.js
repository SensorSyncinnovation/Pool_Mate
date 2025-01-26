const express = require('express');
const router = express.Router();
const User = require('../models/UserSchema');
const multer = require('multer');
const crypto = require('crypto');
const jwt = require('jsonwebtoken');
const nodemailer = require('nodemailer');
const cloudinary = require('cloudinary').v2;
const { CloudinaryStorage } = require('multer-storage-cloudinary');
const admin = require('../firebase');
const SECRET_KEY = "_secret_"; // Replace with a secure key in production
const my_email = "sensorsyncinnovation@gmail.com";
// Configure Nodemailer
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: my_email,
    pass: 'cvnz vsvd jsmg zuto', // Your email password or app-specific password
  },
});

cloudinary.config({
  cloud_name: 'dhurul1ik', // Replace with your Cloudinary cloud name
  api_key: '372333877884267', // Replace with your Cloudinary API key
  api_secret: 'xvhuOc8Ja_Du64B0txtQCLPMmkg', // Replace with your Cloudinary API secret
});

const storage = new CloudinaryStorage({
  cloudinary: cloudinary,
  params: async (req, file) => {
    const fileType = file.mimetype.split('/')[0]; 
    // Only allow images and PDFs
     console.log(fileType);
      return {
        folder: 'pool_mate', // Folder name in your Cloudinary account
        resource_type: fileType === 'image' ? 'image' : 'raw', // Use 'raw' for non-image files like PDFs
        public_id: `${Date.now()}_${file.originalname}`, // Unique file name
      };
  },
});
const upload = multer({ storage });
// POST: Generate OTP or Update Existing User OTP and Send Email
router.post('/email', async (req, res) => {
  try {
    console.log(req.body);
    const { email, phone, fcmToken } = req.body;

    if (!email || !phone) {
      return res.status(400).json({ message: 'Email and phone are required' });
    }

    // Check if the user exists
    let user = await User.findOne({ email: email });
    const otp = crypto.randomInt(100000, 999999);
    if (!user) {
      // Create a new user with OTP, phone, and FCM token
      user = new User({
        email,
        phone,
        otp,
        fcmToken, // Save FCM token
        isDriver: false, // Initially not verified
        joined_pools: [],
        otp_expires_at: new Date(Date.now() + 5 * 60 * 1000), // OTP expires in 5 minutes
      });

      await user.save();
    } else {
      // Update OTP and FCM token for existing user
      user.otp = otp;
      user.otp_expires_at = new Date(Date.now() + 5 * 60 * 1000); // OTP expires in 5 minutes
      user.fcmToken = fcmToken; // Update FCM token
      await user.save();
      console.log("User updated successfully");
    }

    // Send OTP via email
    const mailOptions = {
      from: my_email,
      to: email,
      subject: 'Your OTP for Verification',
      text: `Your OTP is ${otp}. It is valid for 5 minutes.`,
    };

    await transporter.sendMail(mailOptions);

    return res.status(200).json({ message: 'OTP sent to email successfully' });
  } catch (error) {
    console.error('Error during email verification:', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
});

// POST: Verify OTP and Generate JWT
router.post('/verify', async (req, res) => {
  try {
    const { email, otp } = req.body;

    if (!email || !otp) {
      return res.status(400).json({ message: 'Email and OTP are required' });
    }

    // Find the user by email
    const user = await User.findOne({ email });

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Check if the OTP matches and has not expired
    if (user.otp !== otp || new Date() > user.otp_expires_at) {
      return res.status(400).json({ message: 'Invalid or expired OTP' });
    }

    user.otp = null; // Clear OTP after successful verification
    await user.save();

    // Generate JWT
    const token = jwt.sign(
      { id: user._id, email: user.email, phoneNumber: user.phone },
      SECRET_KEY
    );

    let documents = true;
    if (!user.Aadhar_url || !user.License_url) {
      documents = false;
    }

    // Send notification (FCM)
    if (user.fcmToken) {
      const message = {
        notification: {
          title: 'Welcome to Poolmate!',
          body: `Hi ${email}, we're excited to have you on board!`,
        },
        token: user.fcmToken,
      };

      try {
        await admin.messaging().send(message);
        console.log('Notification sent successfully to:', user.fcmToken);
      } catch (error) {
        console.error('Error sending notification:', error);
      }
    } else {
      console.warn('No FCM token available for this user.');
    }

    // Set the token as a cookie without expiration
    res.cookie('token', token);
    return res.status(200).json({
      message: 'OTP verified successfully',
      token,
      email: user.email,
      phoneNumber: user.phone,
      isDriver: user.isDriver,
      documents,
    });
  } catch (error) {
    console.error('Error in /verify route:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

router.post('/license', upload.fields([{ name: 'aadhaar' }, { name: 'license' }]), async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({ message: 'Email is required' });
    }
    console.log(req.files)
    // Check if files were uploaded
    if (!req.files || !req.files.aadhaar || !req.files.license) {
      return res.status(400).json({ message: 'Aadhaar and License files are required' });
    }

    const aadhaarFile = req.files.aadhaar[0];
    const licenseFile = req.files.license[0];

    // Save file URLs to the database
    let user = await User.findOne({ email });

    if (!user) {
      // If user does not exist, create a new one
      user = new User({
        email,
        Aadhar_url: aadhaarFile.path, // Cloudinary URL
        License_url: licenseFile.path, // Cloudinary URL
        isDriver: true, // Mark as verified
      });
      await user.save();
    } else {
      // Update existing user
      user.Aadhar_url = aadhaarFile.path;
      user.License_url = licenseFile.path;
      user.isDriver = true; // Mark as verified
      await user.save();
    }
   console.log("Files Uploaded Success");
   
    res.status(200).json({
      message: 'Files uploaded successfully',
      data: {
        email: user.email,
        phone: user.phone,
        aadhaarUrl: user.Aadhar_url,
        licenseUrl: user.License_url,
        isDriver: user.isDriver,
      },
    });
  } catch (error) {
    console.error('Error uploading files:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});
// GET: Check if User is Verified using JWT from Cookies

router.all('/is-verified', async (req, res) => {
  try {
    const token = req.body.token || req.headers['authorization']?.split(' ')[1];
    if (!token) {
      return res.status(401).json({ message: 'Unauthorized' });
    }

    const decoded = jwt.verify(token, SECRET_KEY);
    const user = await User.findById(decoded.id);

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    let documents  = true
    if(!user.Aadhar_url || !user.License_url){
      documents = false
    }

    return res.status(200).json({
      message: 'success',
      email: user.email,
      phoneNumber: user.phone,
      isDriver: user.isDriver,
      documents:documents
    });
  } catch (error) {
    console.error('Error in /is-verified route:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

module.exports = router;
