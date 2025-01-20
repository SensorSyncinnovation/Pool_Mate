const express = require('express');
const router = express.Router();
const User = require('../models/UserSchema');
const multer = require('multer');
const crypto = require('crypto');
const jwt = require('jsonwebtoken');
const nodemailer = require('nodemailer');
const cloudinary = require('cloudinary').v2;
const { CloudinaryStorage } = require('multer-storage-cloudinary');

const SECRET_KEY = "your_secret_key"; // Replace with a secure key in production
const my_email = "koushik.p22@iiits.in"
// Configure Nodemailer
const transporter = nodemailer.createTransport({
  service: 'gmail', // Use your preferred email service
  auth: {
    user: my_email, // Your email
    pass: 'evpx kleh ppsv zcsy', // Your email password or app-specific password
  },
});

cloudinary.config({
  cloud_name: 'desncpevo', // Replace with your Cloudinary cloud name
  api_key: '346261456696579', // Replace with your Cloudinary API key
  api_secret: 'RIKyOt_3VBDahOJ5NdcIGFlA5JE', // Replace with your Cloudinary API secret
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
    const { email, phone } = req.body;

    if (!email || !phone) {
      return res.status(400).json({ message: 'Email and phone are required' });
    }

    // Check if the user exists
    let user = await User.findOne({ email: email });
    const otp = crypto.randomInt(100000, 999999);
    if (!user) {
      // Create a new user with OTP and phone
      user = new User({
        email,
        phone,
        otp,
        isVerified: false, // Initially not verified
        otp_expires_at: new Date(Date.now() + 5 * 60 * 1000), // OTP expires in 5 minutes
      });

      await user.save();
    } else {
      // Update OTP for existing user
      user.otp = otp;
      user.otp_expires_at = new Date(Date.now() + 5 * 60 * 1000); // OTP expires in 5 minutes
      await user.save().then(()=>{console.log("user saved successfully");
      });
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

    // Mark the user as verified
    user.isVerified = true;
    user.otp = null; // Clear OTP after successful verification
    await user.save();

    // Generate JWT
    const token = jwt.sign({ id: user._id, email: user.email , phone:user.phone }, SECRET_KEY);

    // Set the token as a cookie without expiration and without httpOnly and secure
    res.cookie('token', token);
    
    return res.status(200).json({ message: 'OTP verified successfully' });
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
        aadhaarUrl: user.aadhaarUrl,
        licenseUrl: user.licenseUrl,
      },
    });
  } catch (error) {
    console.error('Error uploading files:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});
// GET: Check if User is Verified using JWT from Cookies
router.get('/is-verified', async (req, res) => {
  try {
    const token = req.cookies.token;

    if (!token) {
      return res.status(401).json({ message: 'Unauthorized' });
    }

    const decoded = jwt.verify(token, SECRET_KEY);
    const user = await User.findById(decoded.id);

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    if (user.isVerified) {
      return res.status(200).json({ message: 'User is already verified' });
    } else {
      return res.status(200).json({ message: 'User is not verified' });
    }
  } catch (error) {
    console.error('Error in /is-verified route:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

module.exports = router;
