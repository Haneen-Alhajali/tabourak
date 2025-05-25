// routes/settingsRoutes.js
const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const settingsController = require('../controllers/settingsController');

router.get('/', authMiddleware, settingsController.getSettings);

module.exports = router;