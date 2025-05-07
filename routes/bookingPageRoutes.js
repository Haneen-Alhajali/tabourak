// routes/bookingPageRoutes.js
const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const bookingPageController = require('../controllers/bookingPageController');

router.post('/', authMiddleware, bookingPageController.createBookingPage);
router.get('/', authMiddleware, bookingPageController.getUserBookingPages);
router.put('/', authMiddleware, bookingPageController.updateBookingPage);

module.exports = router;