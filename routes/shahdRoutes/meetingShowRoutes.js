const express = require('express');
const router = express.Router();
const meetingController = require('../../controllers/shahdController/meetingShowController');

router.get('/meetingsShowPage/:staff_id', meetingController.getMeetingsByStaff);

module.exports = router;
