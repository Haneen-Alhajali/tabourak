const express = require('express');
const router = express.Router();
const controller = require('../../controllers/shahdController/generatedMeetingsController');

router.post('/generated-meetings-for-database', controller.createGeneratedMeeting);
router.post('/get-join-url', controller.getJoinUrlByAppointment);
router.get('/get-meeting-by-id', controller.getMeetingById);

module.exports = router;
