// routes/seasonalAvailabilityRoutes.js
const express = require('express');
const router = express.Router();
const seasonalAvailabilityController = require('../controllers/seasonalAvailabilityController');
const authMiddleware = require('../middleware/authMiddleware');

// Apply auth middleware to all routes
router.use(authMiddleware);

// Get all seasonal availability for a schedule
router.get('/', seasonalAvailabilityController.getSeasonalAvailability);

// Create or update seasonal availability
router.post('/', seasonalAvailabilityController.upsertSeasonalAvailability);

// Delete seasonal availability
router.delete('/:seasonId', seasonalAvailabilityController.deleteSeasonalAvailability);

router.post('/seasonal-availability/check-overlap', authMiddleware, seasonalAvailabilityController.checkDateOverlap);

module.exports = router;