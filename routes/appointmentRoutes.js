// // routes\appointmentRoutes.js
const express = require('express');
const router = express.Router();
const controller = require('../controllers/appointmentController');
const auth = require('../middleware/authMiddleware');

router.get('/types', auth, controller.getUserTypes);
router.post('/preferences', auth, controller.handlePreferences);
router.put('/preferences', auth, controller.handlePreferences);

module.exports = router;


