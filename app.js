require('dotenv').config();
const axios = require('axios');

const express = require('express');
const app = express();
const cors = require('cors');
app.use(cors());





const authRoutes = require('./routes/shahdRoutes/authRoutes');
const otpRoutes = require('./routes/shahdRoutes/otpRoutes');
const calendarRoutes = require('./routes/shahdRoutes/calenderRoutes');
const appointmentRoutes = require('./routes/shahdRoutes/appointmentRoutes');
const customFieldRoutes = require('./routes/shahdRoutes/customFieldRoutes');
const customFieldAnswerRoutes = require('./routes/shahdRoutes/customFieldAnswerRoutes');
const exelSheetRoutes = require('./routes/shahdRoutes/exelSheetRoutes/exelSheetRoute');
const customFileResponsesRoutes = require('./routes/shahdRoutes/customFileResponsesRoutes');
const bookingAvailabilityRoutes = require('./routes/shahdRoutes/bookingAvailabilityRoutes');
const availabilityRoutes = require('./routes/shahdRoutes/getAvailableSlotsWithoutBookedRoutes'); 
const memberRoutes = require('./routes/shahdRoutes/memberRoutes');
const generatedMeetingsRoutes = require('./routes/shahdRoutes/generatedMeetingsRoutes');
const bookingsRoutes = require('./routes/shahdRoutes/bookingEmailRoutes');
const meetingRoutes = require('./routes/shahdRoutes/meetingShowRoutes');
const zoomRoutes = require('./routes/shahdRoutes/zoomRoute');

const getPageIdRoute = require('./routes/shahdRoutes/pageSlugRoutes');




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

app.use('/api', getPageIdRoute); 


app.get('/', (req, res) => {
  res.send('Tabourak Backend is working!');
});


const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
