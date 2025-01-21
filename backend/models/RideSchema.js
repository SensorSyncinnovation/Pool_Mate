const mongoose = require('mongoose');

const RideSchema = mongoose.Schema({
    driver:String,
    driver_phone:String,
    driver_email:String,
    passengers: [{
        id:String,
        name: String,
        phoneNumber: String,
        email: String,
    }],
    pickupLocation: String,
    dropoffLocation: String,
    startTime: String,
    endTime: String,
    distance: Number,
    cost: Number,
    seats_available: Number,
})

module.exports = mongoose.model('Ride', RideSchema);