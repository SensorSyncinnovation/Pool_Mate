const express = require('express');
const router = express.Router();
const Rides = require('../models/RideSchema');
const multer = require('multer');
const crypto = require('crypto');
const jwt = require('jsonwebtoken');
const nodemailer = require('nodemailer');
const cloudinary = require('cloudinary').v2;
const { CloudinaryStorage } = require('multer-storage-cloudinary');
const User = require('../models/UserSchema');

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

function sendRideCreationEmail(ride) {
  const mailOptions = {
      from: my_email,
      to: ride.driver_email,
      subject: 'Ride Created',
      text: `Your ride from ${ride.pickupLocation} to ${ride.dropoffLocation} at ${ride.startTime} has been created. 
      The cost of the ride is ${ride.cost} and there are ${ride.seats_available} seats available.`
  };

  transporter.sendMail(mailOptions, (err, info) => {
      if (err) {
          console.log(err);
      } else {
          console.log(`Email sent to ${ride.driver_email}`);
      }
  });
}

function sendJoinPoolEmail(pool, user, remainingSeats) {
  const mailOptions = {
    from: my_email,
    to: pool.driver_email,
    subject: 'New User Joined Your Pool',
    text: `A new user has joined your pool!
    
Pool Details:
- From: ${pool.pickupLocation} to ${pool.dropoffLocation}
- Date: ${pool.startTime}
- Cost: ${pool.cost}

User Details:
- Email: ${user.email}
- Phone: ${user.phone}

Remaining seats: ${remainingSeats}

Thank you for using Pool Mate!`
  };

  transporter.sendMail(mailOptions, (err, info) => {
    if (err) {
      console.log('Error sending join pool email:', err);
    } else {
      console.log(`Join pool notification sent to ${pool.driver_email}`);
    }
  });
}

function sendLeavePoolEmail(pool, user, remainingSeats) {
  const mailOptions = {
    from: my_email,
    to: pool.driver_email,
    subject: 'User Left Your Pool',
    text: `A user has left your pool.
    
Pool Details:
- From: ${pool.pickupLocation} to ${pool.dropoffLocation}
- Date: ${pool.startTime}
- Cost: ${pool.cost}

User Details:
- Email: ${user.email}
- Phone: ${user.phone}

Remaining seats: ${remainingSeats}

Thank you for using Pool Mate!`
  };

  transporter.sendMail(mailOptions, (err, info) => {
    if (err) {
      console.log('Error sending leave pool email:', err);
    } else {
      console.log(`Leave pool notification sent to ${pool.driver_email}`);
    }
  });
}

router.get('/rides', async  (req, res)=> {
  const currentTime = new Date(); // Get the current date and time
  try {
      const rides = await Rides.find({ startTime: { $gt: currentTime } }).exec();
      res.json(rides);
  } catch (err) {
      res.status(500).send(err);
  }
});

router.post('/rides', async (req, res) => {
  try {

      const ride = new Rides({
          driver: "",
          passengers: [],
          pickupLocation: req.body.pickupLocation,
          dropoffLocation: req.body.dropoffLocation,
          startTime: req.body.startTime,
          cost: req.body.cost,
          seats_available: Number(req.body.seats_available),
          driver_phone:req.body.driver_phone,
          driver_email:req.body.driver_email,
      });

      const savedRide = await ride.save();
      sendRideCreationEmail(savedRide);
      res.status(201).json(savedRide);
  } catch (error) {
      console.log(error);
      res.status(500).json({ message: 'Failed to create ride', error });
  }
});

router.post('/findride', async (req, res) => {
  const { pickupLocation, dropoffLocation } = req.body;
  try {
      const rides = await Rides.find({
          pickupLocation,
          dropoffLocation,
      }).exec();
      res.json(rides);
  } catch (err) {
      res.status(500).send(err);
  }
});

router.get('/mypools/:email', async (req, res) => {
  try {
      const { email } = req.params;
      const response = await Rides.find({ driver_email: email }).exec();
      if (response.length === 0) {
          return res.status(404).json({ message: 'No pools found for this user' });
      }
      res.status(200).json(response);
  } catch (error) {
      console.log(error);
      res.status(500).json({ message: 'Failed to fetch pools', error });
  }
});

router.delete('/pool/:id', async (req, res) => {
  try {
      const id = req.params.id;
      const response = await Rides.findByIdAndDelete(id).exec();
      if (!response) {
          return res.status(404).json({ message: 'Pool not found' });
      }
      res.status(200).json({ message: 'Pool deleted successfully' });
  } catch (error) {
      console.log(error);
      res.status(500).json({ message: 'Failed to delete pool', error });
  }
});
// POST: Add a passenger to a pool
router.post('/add-passenger', async (req, res) => {
  try {
      const { poolId, email } = req.body;
      const response = await Rides.findByIdAndUpdate(
          poolId,
          {
              $push: {
                  passengers: {
                      id: email,
                      name: req.body.name,
                      phoneNumber: req.body.phoneNumber,
                      email: req.body.email,
                  },
              },
          },
          { new: true } // returns the updated document
      );
      res.status(200).json(response);
  } catch (error) {
      res.status(500).json({ message: 'Failed to add passenger', error });
  }
});

// DELETE: Remove a passenger from a pool
router.delete('/remove-passenger', async (req, res) => {
  try {
      const { poolId, email } = req.body;
      const response = await Rides.findByIdAndUpdate(
          poolId,
          {
              $pull: {
                  passengers: {
                      id: email,
                  },
              },
          },
          { new: true } // returns the updated document
      );
      res.status(200).json(response);
  } catch (error) {
      res.status(500).json({ message: 'Failed to remove passenger', error });
  }
});


// GET: Retrieve a particular ride by ID
router.get('/rides/:id', async (req, res) => {
  try {
      const ride = await Rides.findById(req.params.id);
      if (!ride) {
          return res.status(404).json({ message: 'Ride not found' });
      }
      res.status(200).json(ride);
  } catch (error) {
      res.status(500).json({ message: 'Failed to retrieve ride', error });
  }
});
// PUT: Update a particular ride by ID
router.put('/rides/:id', async (req, res) => {
  try {
      const updatedRide = await Rides.findByIdAndUpdate(
          req.params.id,
          {
              driver: req.body.driver,
              passengers: req.body.passengers,
              pickupLocation: req.body.pickupLocation,
              dropoffLocation: req.body.dropoffLocation,
              startTime: req.body.startTime,
              endTime: req.body.endTime,
              distance: req.body.distance,
              cost: req.body.cost,
              seats_availabe: req.body.seats_availabe,
          },
          { new: true } // returns the updated document
      );

      if (!updatedRide) {
          return res.status(404).json({ message: 'Ride not found' });
      }

      res.status(200).json(updatedRide);
  } catch (error) {
      res.status(500).json({ message: 'Failed to update ride', error });
  }
});
// DELETE: Delete a particular ride by ID
router.delete('/rides/:id', async (req, res) => {
  try {
      const deletedRide = await Rides.findByIdAndDelete(req.params.id);
      if (!deletedRide) {
          return res.status(404).json({ message: 'Ride not found' });
      }
      res.status(200).json({ message: 'Ride deleted successfully' });
  } catch (error) {
      res.status(500).json({ message: 'Failed to delete ride', error });
  }
});

// Get joined pools for a user
router.get('/user/joined-pools/:email', async (req, res) => {
  try {
    const user = await User.findOne({ email: req.params.email });
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    
    // Fetch all rides that the user has joined
    const joinedRides = await Rides.find({ _id: { $in: user.joined_pools } });
    res.json(joinedRides);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Join a pool
router.post('/user/join-pool', async (req, res) => {
  try {
    const { email, poolId } = req.body;
    
    // Check if pool exists and has available seats
    const pool = await Rides.findById(poolId);
    if (!pool) {
      return res.status(404).json({ message: 'Pool not found' });
    }

    if (pool.seats_available <= 0) {
      return res.status(400).json({ message: 'No seats available in this pool' });
    }

    // Get user details
    const user = await User.findOneAndUpdate(
      { email },
      { $addToSet: { joined_pools: poolId } },
      { new: true }
    );

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Decrease available seats
    const updatedPool = await Rides.findByIdAndUpdate(
      poolId,
      { $inc: { seats_available: -1 } },
      { new: true }
    );

    // Send email notification
    sendJoinPoolEmail(updatedPool, user, updatedPool.seats_available);

    res.json({ 
      message: 'Successfully joined pool', 
      user,
      pool: updatedPool
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Leave a pool
router.delete('/user/leave-pool', async (req, res) => {
  try {
    const { email, poolId } = req.body;
    
    // Get user details first
    const user = await User.findOneAndUpdate(
      { email },
      { $pull: { joined_pools: poolId } },
      { new: true }
    );

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Increase available seats when user leaves
    const updatedPool = await Rides.findByIdAndUpdate(
      poolId,
      { $inc: { seats_available: 1 } },
      { new: true }
    );

    // Send email notification
    sendLeavePoolEmail(updatedPool, user, updatedPool.seats_available);

    res.json({ 
      message: 'Successfully left pool', 
      user,
      pool: updatedPool
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;