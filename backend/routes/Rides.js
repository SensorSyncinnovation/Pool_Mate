const express = require('express');
const router = express.Router();
const Rides = require('../models/RideSchema');
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


router.get('/rides', function (req, res) {
    Rides.find({}, function (err, rides) {
        if (err) return res.status(500).send(err);
        res.json(rides);
    });
})