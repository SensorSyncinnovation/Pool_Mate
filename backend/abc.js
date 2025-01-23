import nodemailer from 'nodemailer';
import mongoose from 'mongoose';

const my_email = "sensorsyncinnovation@gmail.com";
const uri = 'mongodb+srv://sensorsyncinnovation:SreeH2025!@cluster0.jpksx.mongodb.net/pool_mate';

// Function to connect to MongoDB
async function connectDB() {
  try {
    await mongoose.connect(uri, { useNewUrlParser: true, useUnifiedTopology: true });
    console.log("Connected to MongoDB!");
  } catch (error) {
    console.error("Failed to connect to MongoDB:", error.message);
  }
}

// Call the function to connect
connectDB();

// Configure Nodemailer
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: my_email,
    pass: 'cvnz vsvd jsmg zuto', // Your email password or app-specific password
  },
});

const mailOptions = {
  from: my_email,
  to: '"pinnukoushikp@gmail.com"',
  subject: 'Test',
  text: `This is a test email.`,
};

// Send the email
(async () => {
  try {
    const info = await transporter.sendMail(mailOptions);
    console.log("Email sent successfully:", info.response);
  } catch (error) {
    console.error("Error while sending email:", error.message);
  }
})();
