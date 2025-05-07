// // routes\appointmentRoutes.js
const express = require('express');
const router = express.Router();
const controller = require('../controllers/appointmentController');
const auth = require('../middleware/authMiddleware');

router.get('/', auth, controller.getUserAppointments);
router.post('/', auth, controller.handleAppointments);

module.exports = router;


