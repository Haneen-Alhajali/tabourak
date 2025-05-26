const express = require('express');
const router = express.Router();
const appointmentController = require('../../controllers/shahdController/appointmentController');

router.get('/:id', appointmentController.getAppointmentDetails);
router.put('/:id', appointmentController.updateAppointmentDetails);
router.get('/page/:pageId', appointmentController.getAppointmentsByPage);

module.exports = router;
