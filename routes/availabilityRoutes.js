// routes/availabilityRoutes.js
const express = require('express');
const router = express.Router();
const availabilityController = require('../controllers/availabilityController');
const authMiddleware = require('../middleware/authMiddleware');

// Apply auth middleware to all routes
router.use(authMiddleware);

// Save availability
router.post('/', availabilityController.saveAvailability);

// Get availability
router.get('/', availabilityController.getAvailability);

module.exports = router;