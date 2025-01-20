const mongoose = require('mongoose');

const RideSchema = mongoose.Schema({
    driver:String,
    passengers: [{
        id:String,
        name: String,
        phoneNumber: String,
        email: String,
    }],
    pickupLocation: String,
    dropoffLocation: String,
    startTime: Date,
    endTime: Date,
    distance: Number,
    cost: Number,
    seats_availabe: Number,
})