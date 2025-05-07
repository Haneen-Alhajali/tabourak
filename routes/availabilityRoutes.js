// routes/availabilityRoutes.js
const express = require('express');
const router = express.Router();
const availabilityController = require('../controllers/availabilityController');
const authMiddleware = require('../middleware/authMiddleware');

// Apply auth middleware to all routes
router.use(authMiddleware);

// Get availability
router.get('/', availabilityController.getAvailability);

// Update availability
router.put('/', availabilityController.updateAvailability);

module.exports = router;
