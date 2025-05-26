// app.js
require("dotenv").config();
const axios = require("axios");
const express = require("express");
const cors = require("cors");
const app = express();

// Enhanced CORS configuration
app.use(
  cors({
    origin: "*", // Allow all origins for development
    methods: ["GET", "POST", "PUT", "DELETE"],
    allowedHeaders: ["Content-Type", "Authorization"],
  })
);

// Increase request size limit
app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: true, limit: "10mb" }));










// Routes
app.use("/api/auth", require("./routes/authRoutes"));
app.use("/api/appointments", require("./routes/appointmentRoutes"));
app.use("/api/availability", require("./routes/availabilityRoutes"));
app.use("/api/booking-pages", require("./routes/bookingPageRoutes"));
app.use("/api/upload", require("./routes/uploadRoutes"));
app.use("/uploads", express.static("public/uploads")); // Serve uploaded files
app.use("/api/user", require("./routes/userRoutes"));
app.use("/api/meeting-types", require("./routes/meetingTypeRoutes"));
app.use("/api/user-profile", require("./routes/userProfileRoutes"));
app.use("/api/schedules", require("./routes/scheduleRoutes"));
app.use("/api/profile", require("./routes/ProfileRoutes"));
app.use("/api/seasonal-availability",require("./routes/seasonalAvailabilityRoutes"));
app.use("/api/date-specific-availability",require("./routes/dateSpecificAvailabilityRoutes"));
app.use("/api/settings", require("./routes/settingsRoutes"));

// Test endpoint
app.get("/api/health", (req, res) => {
  res.status(200).json({ status: "OK" });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: "Internal Server Error" });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, "0.0.0.0", () => {
  // Listen on all network interfaces
  console.log(`Server running on port ${PORT}`);
});


///////////////////////////////////////////////////////////////////////////////

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






