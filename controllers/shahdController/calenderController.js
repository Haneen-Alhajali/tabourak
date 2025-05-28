//C:\Users\User\Desktop\Flutter BackEnd\tabourak-backend\controllers\calenderController.js
const { google } = require('googleapis');
const calendarModel = require('../../models/shahdModels/calenderModel');
const jwt = require("jsonwebtoken");
const db = require('../../config/db');

const { getCalendarDetails } =require('../../services/calendarService');

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



//////////////////////////////////////////////////////////////////////////////////
exports.createCalendarEvent = async (req, res) => {
  const { userId, summary, description, startTime, endTime } = req.body;

  try {

    console.log("✅✅startTime "+startTime);
    console.log("✅✅endTime "+endTime);

    const query = `
      SELECT access_token 
      FROM calendar_integrations 
      WHERE member_id = ? AND is_connected = TRUE
      LIMIT 1
    `;

    db.query(query, [userId], async (err, results) => {
      if (err) {
        console.error('❌ DB error:', err);
        return res.status(500).json({ message: 'Database error' });
      }

      if (results.length === 0) {
        return res.status(404).json({ message: 'No connected calendar for this user' });
      }

      const accessToken = results[0].access_token;

      // تهيئة Google Calendar API
      const oauth2Client = new google.auth.OAuth2();
      oauth2Client.setCredentials({ access_token: accessToken });

      const calendar = google.calendar({ version: 'v3', auth: oauth2Client });

      const event = {
        summary,
        description,
        start: {
          dateTime: new Date(startTime).toISOString(),
          timeZone: 'Asia/Riyadh',
        },
        end: {
          dateTime: new Date(endTime).toISOString(),
          timeZone: 'Asia/Riyadh',
        },
      };

      const response = await calendar.events.insert({
        calendarId: 'primary',
        requestBody: event,
      });

      return res.status(200).json({ message: 'Event created successfully', eventId: response.data.id });
    });
  } catch (error) {
    console.error('❌ Error creating event:', error);
    return res.status(500).json({ message: 'Failed to create event', error: error.message });
  }
};
