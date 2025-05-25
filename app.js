require('dotenv').config();
const axios = require('axios');

const express = require('express');
const app = express();
const cors = require('cors');
app.use(cors());

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


const memberRoutes = require('./routes/memberRoutes');

const generatedMeetingsRoutes = require('./routes/generatedMeetingsRoutes');
const bookingsRoutes = require('./routes/bookingEmailRoutes');
const meetingRoutes = require('./routes/meetingShowRoutes');



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

app.use('/api', memberRoutes); 


app.use('/api', generatedMeetingsRoutes); 
app.use('/api', bookingsRoutes);
app.use('/api', meetingRoutes);  



app.use('/zoom', zoomRoutes);



app.get('/', (req, res) => {
  res.send('Tabourak Backend is working!');
});



app.listen(3000, '0.0.0.0', () => {
  console.log('Server running on http://localhost:3000');
});