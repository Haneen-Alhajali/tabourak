//C:\Users\User\Desktop\Flutter BackEnd\tabourak-backend\routes\calenderRoutes.js
const express = require('express');
const router = express.Router();

const calendarController = require('../../controllers/shahdController/calenderController');

router.post('/connect', calendarController.connectCalendar);
router.get('/info', calendarController.getCalendarInfo);

module.exports = router;

