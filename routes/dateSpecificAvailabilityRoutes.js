// routes/dateSpecificAvailabilityRoutes.js
const express = require('express');
const router = express.Router();
const dateSpecificAvailabilityController = require('../controllers/dateSpecificAvailabilityController');
const authMiddleware = require('../middleware/authMiddleware');

// Apply auth middleware to all routes
router.use(authMiddleware);

// Get all date-specific availability for a schedule
router.get('/', dateSpecificAvailabilityController.getDateSpecificAvailability);

// Update date-specific availability
router.put('/', dateSpecificAvailabilityController.updateDateSpecificAvailability);

module.exports = router;