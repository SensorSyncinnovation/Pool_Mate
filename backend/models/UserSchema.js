const mongoose = require('mongoose')

const UserSchema = mongoose.Schema({
    name: { type: String },
    role: { type: String },
    email:String,
    phone:String,
    otp:String,
    otp_expires_at:Date,
    isDriver:Boolean,
    Aadhar_url:String , 
    License_url:String,
    created_at: { type: Date, default: Date.now },
    joined_pools:[String],
    updated_at: { type: Date, default: Date.now }
})

module.exports = mongoose.model('User', UserSchema)
