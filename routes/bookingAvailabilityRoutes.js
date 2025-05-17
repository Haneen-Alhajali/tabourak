

const express = require('express');
const router = express.Router();
const availabilityController = require('../controllers/bookingAvailabilityController');

router.get('/availability/next-14-days', availabilityController.getTwoWeeksAvailability);

module.exports = router;
