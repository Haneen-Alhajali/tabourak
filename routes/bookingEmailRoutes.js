// routes/booking.js
const express = require('express');
const router = express.Router();
const bookingController = require('../controllers/bookingEmailController');

router.get('/booking/:bookingId/cancel', bookingController.cancelBooking);
router.get('/booking/:bookingId/confirm', bookingController.confirmBooking);

module.exports = router;
