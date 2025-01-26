const mongoose = require('mongoose')

const UserSchema = mongoose.Schema({
    name: { type: String },
    role: { type: String },
    email:{type:String , unique:true},
    phone:{type:String},
    fcmToken:{type:String},
    otp:{type:String},
    otp_expires_at:{type:Date},
    isDriver:{type:Boolean},
    Aadhar_url:{type:String} , 
    License_url:{type:String},
    created_at: { type: Date, default: Date.now },
    joined_pools:[{
        id:String,
        driver_phone:String,
        driver_email:String,
        driver_fcms: String,
        pickupLocation: String,
        dropoffLocation: String,
        startTime: String,
    }],
    history:[String],
    updated_at: { type: Date, default: Date.now }
})

module.exports = mongoose.model('User', UserSchema)
