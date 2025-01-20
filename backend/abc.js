// const nodemailer = require('nodemailer')
import nodemailer from 'nodemailer'
const my_email = "koushik.p22@iiits.in"
// Configure Nodemailer
const transporter = nodemailer.createTransport({
  service: 'gmail', // Use your preferred email service
  auth: {
    user: my_email, // Your email
    pass: 'evpx kleh ppsv zcsy', // Your email password or app-specific password
  },
});

const mailOptions = {
    from: my_email,
    to: 'pinnukousihkp@gmail.com',
    subject: 'Your OTP for Verification',
    text: `Your OTP `,
  };

  await transporter.sendMail(mailOptions);
