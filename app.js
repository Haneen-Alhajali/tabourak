require('dotenv').config();
const axios = require('axios');

const express = require('express');
const app = express();
const authRoutes = require('./routes/authRoutes');
const otpRoutes = require('./routes/otpRoutes');
const calendarRoutes = require('./routes/calenderRoutes');
const appointmentRoutes = require('./routes/appointmentRoutes');
const customFieldRoutes = require('./routes/customFieldRoutes');
const customFieldAnswerRoutes = require('./routes/customFieldAnswerRoutes');

const exelSheetRoutes = require('./routes/exelSheetRoutes/exelSheetRoute');
const customFileResponsesRoutes = require('./routes/customFileResponsesRoutes');

const bookingAvailabilityRoutes = require('./routes/bookingAvailabilityRoutes');
const availabilityRoutes = require('./routes/getAvailableSlotsWithoutBookedRoutes'); 



const zoomRoutes = require('./routes/zoomRoute');


app.use(express.json());

app.use('/api/auth', authRoutes);
app.use('/api/otp', otpRoutes);
app.use('/api/calendar', calendarRoutes);
app.use('/api/appointment', appointmentRoutes);
app.use('/api', customFieldRoutes);
app.use('/api', customFieldAnswerRoutes);


app.use('/api', exelSheetRoutes);
app.use('/api', customFileResponsesRoutes);



app.use('/api', bookingAvailabilityRoutes);
app.use('/api', availabilityRoutes); // 










app.use('/zoom', zoomRoutes);



app.get('/', (req, res) => {
  res.send('Tabourak Backend is working!');
});

///////////////////////////////////////////////////////////////////////////////////////
/*
app.get("/api/zoom/auth", (req, res) => {
  const redirect_uri = "http://localhost:3000/api/zoom/callback";
  const client_id = "AofrtcAhRLOl0mTxiFEx8w";
  const zoomAuthURL = `https://zoom.us/oauth/authorize?response_type=code&client_id=${client_id}&redirect_uri=${redirect_uri}`;
  res.redirect(zoomAuthURL);
});

app.get("/api/zoom/callback", async (req, res) => {
  const code = req.query.code;
  const redirect_uri = "http://localhost:3000/api/zoom/callback";

  try {
    const response = await axios.post("https://zoom.us/oauth/token", null, {
      params: {
        grant_type: "authorization_code",
        code,
        redirect_uri,
      },
      auth: {
        username: "CwfOqO_DSYq54KS7R5rxeg",
        password: "NRQqC1s4KvlXlBI4MMugXMD5LH98HvSz",
      },
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
    });

    const { access_token, refresh_token } = response.data;
    res.send("Zoom connected successfully!");
  } catch (error) {
    console.error("Zoom Error:", error.response?.data || error.message);
    res.status(500).json({ error: error.response?.data || "Zoom request failed" });
  }
});



app.post("/api/zoom/create-meeting", async (req, res) => {
  const { accessToken, topic, startTime, duration } = req.body;

  const meeting = await axios.post(
    "https://api.zoom.us/v2/users/me/meetings",
    {
      topic,
      type: 2, // Scheduled Meeting
      start_time: startTime,
      duration, // 
      settings: {
        join_before_host: false,
        waiting_room: true,
      },
    },
    {
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
    }
  );

  res.json(meeting.data);
});*/

//////////////////////////////////////////////////////////////////////////////////////


app.listen(3000, '0.0.0.0', () => {
  console.log('Server running on http://localhost:3000');
});