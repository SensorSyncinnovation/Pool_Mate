// Install Twilio SDK: npm install twilio
const twilio = require("twilio");

// Replace these values with your actual Twilio credentials
const accountSid = "ACb79a7e3ceb5ece9335ede51125f8128c";
const authToken = "1150e1ce626e02b9729c7eded26dbdc4";
const client = twilio(accountSid, authToken);

// Send an SMS
async function sendSms() {
  try {
    const message = await client.messages.create({
      body: "Hello, this is a test message from Twilio!",
      from: "+15673444075", // Replace with your Twilio phone number
      to: "+918019570982"   // Replace with the recipient's phone number
    });    console.log(`Message sent with SID: ${message.sid}`);
  } catch (error) {
    console.error(`Failed to send SMS: ${error.message}`);
  }
}

sendSms();
