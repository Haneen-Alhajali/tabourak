// routes/meetingPreferencesRoutes.js
const express = require('express');
const router = express.Router();
const meetingPreferencesController = require('../controllers/meetingPreferencesController');
const authMiddleware = require('../middleware/authMiddleware');

// Apply authentication middleware to all routes in this file
router.use(authMiddleware);

// GET user's meeting preferences
router.get('/', meetingPreferencesController.getUserPreferences);

// POST to save user's meeting preferences
router.post('/', meetingPreferencesController.saveUserPreferences);

module.exports = router;