//C:\Users\User\Desktop\Flutter BackEnd\tabourak-backend\controllers\calenderController.js
const { google } = require('googleapis');
const calendarModel = require('../models/calenderModel');
const jwt = require("jsonwebtoken");

const { getCalendarDetails } =require('../services/calendarService');


exports.connectCalendar = async (req, res) => {
  try {
    console.log(req.body);
    const { accessToken, email ,globalAuthToken,refreshToken} = req.body;

    const decoded = jwt.verify(globalAuthToken, process.env.JWT_SECRET);

    const userId = decoded.id;
  
    if (!accessToken || !email || !userId) {
      return res.status(400).json({ message: 'Missing required fields' });
    }

    const oauth2Client = new google.auth.OAuth2();
    oauth2Client.setCredentials({ access_token: accessToken });


    const calendar = google.calendar({ version: 'v3', auth: oauth2Client });
    const calendarList = await calendar.calendarList.list();

    calendarModel.saveGoogleCalendarIntegration(
      userId,
      email,
      accessToken,
      refreshToken || null,
      (err) => {
        if (err) {
          console.error('Database error:', err);
          return res.status(500).json({ message: 'Failed to store integration'+err });
        }

        return res.status(200).json({
          message: 'Google Calendar connected successfully',
          calendars: calendarList.data.items,
        });
      }
    );
  } catch (error) {
    console.error('Google Calendar Error:', error);
    return res.status(500).json({
      message: 'Failed to connect to Google Calendar'+error,
      error: error.message,
    });
  }
};




exports.getCalendarInfo = async (req, res) => {
  const accessToken = req.headers.authorization?.split(' ')[1];

  if (!accessToken) {
    return res.status(401).json({ message: 'Missing token' });
  }

  try {
    const calendarData = await getCalendarDetails(accessToken);
    return res.status(200).json(calendarData);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to fetch calendar data' });
  }
};


