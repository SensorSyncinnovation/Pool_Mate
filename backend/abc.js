const mongoose = require('mongoose');
const User = require("./models/UserSchema")

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

// Function to create a sample user
async function createSampleUser() {
  try {
    const sampleUser = new User({
      name: "John Doe",
      role: "User",
      email: "johndoe@example.com",
      phone: "1234567890",
      otp: "654321", // Example OTP
      otp_expires_at: new Date(Date.now() + 5 * 60 * 1000), // OTP valid for 5 minutes
      isDriver: false,
      Aadhar_url: null,
      License_url: null,
      joined_pools: [],
    });

    const savedUser = await sampleUser.save();
    console.log("Sample user created successfully:", savedUser);
  } catch (error) {
    console.error("Error while creating sample user:", error.message);
  }
}

// Connect to DB and create user
(async () => {
  await connectDB();
  await createSampleUser();
  mongoose.connection.close(); // Close the connection after completion
})();
