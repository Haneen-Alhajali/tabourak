// routes/zoom.js
const express = require('express');
const axios = require('axios');
const router = express.Router();
require('dotenv').config();

const CLIENT_ID = process.env.ZOOM_CLIENT_ID;
const CLIENT_SECRET = process.env.ZOOM_CLIENT_SECRET;
const REDIRECT_URI = process.env.ZOOM_REDIRECT_URI;

// 1. توليد رابط الدخول
router.get('/auth', (req, res) => {
  const zoomAuthUrl = `https://zoom.us/oauth/authorize?response_type=code&client_id=${CLIENT_ID}&redirect_uri=${REDIRECT_URI}`;
  res.redirect(zoomAuthUrl);
});

// 2. استقبال الكود وتبديله بتوكن
router.get('/callback', async (req, res) => {
  const { code } = req.query;

  try {
    const tokenResponse = await axios.post(
      'https://zoom.us/oauth/token',
      null,
      {
        params: {
          grant_type: 'authorization_code',
          code,
          redirect_uri: REDIRECT_URI
        },
        auth: {
          username: CLIENT_ID,
          password: CLIENT_SECRET
        }
      }
    );

    const { access_token, refresh_token } = tokenResponse.data;


    res.json({ access_token, refresh_token });
  } catch (error) {
    console.error('🔴 Error exchanging code for token:', error.response?.data || error.message);
    res.status(500).json({ error: 'Failed to get access token from Zoom' });
  }
});





// إنشاء اجتماع جديد
router.post('/create-meeting', async (req, res) => {
  const  access_token  = "eyJzdiI6IjAwMDAwMiIsImFsZyI6IkhTNTEyIiwidiI6IjIuMCIsImtpZCI6IjQyNGYwYjgyLTI5MTYtNGI4Ni04NTYwLTQzODlhZTVlYWY1NSJ9.eyJhdWQiOiJodHRwczovL29hdXRoLnpvb20udXMiLCJ1aWQiOiJBQUcwNFhvM1RYT0xEMHNtd0JPRWdnIiwidmVyIjoxMCwiYXVpZCI6ImY1ZDQ3MTg1Mjc5MTAyYzkxNjU2NjI3ODhmZGNhOWZlZjc1ODA4MTZhZTA3ZDM4MmI4ZjVkNWNmY2UyZThlMWEiLCJuYmYiOjE3NDcyNTczNzksImNvZGUiOiI4Slg2NjNWZE5pQkN6VjdxemplUWdxTkszSVZuRk02WVEiLCJpc3MiOiJ6bTpjaWQ6ZFJRUzlCeVpTVVdCS0Fld3FXUTgyUSIsImdubyI6MCwiZXhwIjoxNzQ3MjYwOTc5LCJ0eXBlIjowLCJpYXQiOjE3NDcyNTczNzksImFpZCI6IkN3Zk9xT19EU1lxNTRLUzdSNXJ4ZWcifQ.ijb_by09Gx930yyG57XIqUr0X40nQWVu5ZxlCDFGBbr6CAL__3bn-0VQTV4n4-cd5Tiqfind9oTxcbk0Tj7s3w"; 
  const userId = 'me'; // "me" تعني المستخدم الحالي

  try {
    const response = await axios.post(
      `https://api.zoom.us/v2/users/${userId}/meetings`,
      {
        topic: 'اجتماع طابورك',
        type: 2, // Meeting Type: Scheduled
        start_time: '2025-05-10T15:00:00Z', // بصيغة UTC
        duration: 30, // بالدقائق
        timezone: 'Asia/Riyadh',
        settings: {
          join_before_host: true,
          approval_type: 0,
          meeting_authentication: false
        }
      },
      {
        headers: {
          Authorization: `Bearer ${access_token}`,
          'Content-Type': 'application/json'
        }
      }
    );

    res.json(response.data);
  } catch (error) {
    console.error('🔴 Error creating Zoom meeting:', error.response?.data || error.message);
    res.status(500).json({ error: 'فشل في إنشاء الاجتماع' });
  }
});


module.exports = router;
