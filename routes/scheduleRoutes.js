// routes/scheduleRoutes.js
const express = require('express');
const router = express.Router();
const scheduleController = require('../controllers/scheduleController');
const authMiddleware = require('../middleware/authMiddleware');

// Apply auth middleware to all routes
router.use(authMiddleware);

// Get all schedules for current user
router.get('/', scheduleController.getMemberSchedules);

// Get timezone options
router.get('/timezones', scheduleController.getTimezoneOptions);

// Create new schedule
router.post('/', scheduleController.createSchedule);

// Update a schedule
router.put('/:id', scheduleController.updateSchedule);

// Delete a schedule
router.delete('/:id', scheduleController.deleteSchedule);

module.exports = router;