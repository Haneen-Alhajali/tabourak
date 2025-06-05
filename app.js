require('dotenv').config();
const axios = require('axios');

const express = require('express');
const app = express();

app.use((req, res, next) => {
  res.setHeader('Access-Control-Allow-Origin', '*'); 
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, DELETE');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  next();
});



const cors = require('cors');


const allowedOrigins = [
  'http://localhost:3000',
  'http://localhost:4200',
  'http://127.0.0.1:5500',
  'http://localhost:5173',
  'http://localhost:8000',
  'https://tabourak-dab3d.web.app', // Flutter Web URL
  'https://2218-178-130-171-122.ngrok-free.app' 
];

app.use(cors({
  origin: allowedOrigins,
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  credentials: true
}));


/*
const cors = require('cors');
app.use(cors({
  origin: '*', 
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

*/



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



const stripeRoutes = require('./routes/stripeRoute');











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

app.use('/api', stripeRoutes);




app.get('/', (req, res) => {
  res.send('Tabourak Backend is working!');
});



app.listen(3000, '0.0.0.0', () => {
  console.log('Server running on http://localhost:3000');
});