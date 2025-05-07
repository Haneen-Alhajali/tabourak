// routes/meetingTypeRoutes.js
const express = require('express');
const router = express.Router();
const meetingTypeController = require('../controllers/meetingTypeController');
const authMiddleware = require('../middleware/authMiddleware');

router.use(authMiddleware);

router.get('/', meetingTypeController.getMeetingTypes);
router.post('/', meetingTypeController.createMeetingType);
router.delete('/:appointmentId', meetingTypeController.deleteMeetingType);

module.exports = router;