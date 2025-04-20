require('dotenv').config();
const express = require('express');
const app = express();
const authRoutes = require('./routes/authRoutes');

app.use(express.json());

app.use('/api/auth', authRoutes);

app.get('/', (req, res) => {
  res.send('Tabourak Backend is working!');
});

app.listen(3000, '0.0.0.0', () => {
  console.log('Server running on http://localhost:3000');
});