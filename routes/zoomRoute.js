// routes/zoom.js
const express = require('express');
const axios = require('axios');
const router = express.Router();
require('dotenv').config();
const db = require('../config/db'); // اتصال قاعدة البيانات

const CLIENT_ID = process.env.ZOOM_CLIENT_ID;
const CLIENT_SECRET = process.env.ZOOM_CLIENT_SECRET;
const REDIRECT_URI = process.env.ZOOM_REDIRECT_URI;

// 1. توليد رابط الدخول
router.get('/auth', (req, res) => {
  const zoomAuthUrl = `https://zoom.us/oauth/authorize?response_type=code&client_id=${CLIENT_ID}&redirect_uri=${REDIRECT_URI}`;
  res.redirect(zoomAuthUrl);
});

router.get('/callback', async (req, res) => {

  const { code, state } = req.query;
  const member_id = state; // استخدمي state كـ member_id
  

  try {
    // Step 1: Exchange code for token
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

    const { access_token, refresh_token, expires_in } = tokenResponse.data;

    // Step 2: Get user email from Zoom
    const userResponse = await axios.get('https://api.zoom.us/v2/users/me', {
      headers: {
        Authorization: `Bearer ${access_token}`
      }
    });

    const account_email = userResponse.data.email;

    // Step 3: احسبي وقت انتهاء التوكن
    const expires_at = new Date(Date.now() + expires_in * 1000); 

    // Step 4: خزن في قاعدة البيانات

    
    // Step 4: خزني البيانات في قاعدة البيانات
    const query = `
      INSERT INTO video_integrations 
        (member_id, provider, access_token, refresh_token, expires_at, account_email)
      VALUES (?, 'zoom', ?, ?, ?, ?)
      ON DUPLICATE KEY UPDATE
        access_token = VALUES(access_token),
        refresh_token = VALUES(refresh_token),
        expires_at = VALUES(expires_at),
        account_email = VALUES(account_email),
        updated_at = CURRENT_TIMESTAMP
    `;

    const values = [member_id, access_token, refresh_token, expires_at, account_email];

    console.log("♻️♻️♻️member_id"+member_id);


    db.query(query, values, (err, result) => {
      if (err) {
        console.error('❌ Database Error:', err);
        return res.status(500).send('Failed to save Zoom tokens');
      }

      // Step 5: رجّعي المستخدم لتطبيقك
      const deepLink = `tabourak://zoom-auth-success`;
      res.redirect(deepLink);
    });



  } catch (error) {
    console.error('❌ Error:', error.response?.data || error.message);
    res.status(500).send('Zoom integration failed');
  }
});


router.post('/create-meeting', async (req, res) => {
  const {
    topic,
    start_time,
    duration,
    timezone,
    member_id
  } = req.body;

  const getTokenQuery = `
    SELECT access_token FROM video_integrations
    WHERE member_id = ? AND provider = 'zoom'
  `;

  db.query(getTokenQuery, [member_id], async (err, results) => {
    if (err) {
      console.error('❌ Error fetching token:', err);
      return res.status(500).json({ error: 'حدث خطأ أثناء جلب التوكن' });
    }

    if (results.length === 0) {
      return res.status(404).json({ error: 'لا يوجد توكن مسجل لهذا العضو' });
    }

    const access_token = results[results.length - 1].access_token;

    try {
      const response = await axios.post(
        `https://api.zoom.us/v2/users/me/meetings`,
        {
          topic: topic || 'اجتماع طابورك',
          type: 2,
          start_time,
          duration: duration || 30,
          timezone: timezone || 'Asia/Riyadh',
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

      // ✅ نرجّع فقط المعلومات المهمة
      res.json({
        id: response.data.id,
        start_url: response.data.start_url,
        join_url: response.data.join_url,
        topic: response.data.topic,
        start_time: response.data.start_time
      });

    } catch (error) {
      console.error('🔴 Error creating Zoom meeting:', error.response?.data || error.message);
      res.status(500).json({ error: 'فشل في إنشاء الاجتماع' });
    }
  });
});




// حذف اجتماع زوم باستخدام meetingId و member_id
router.post('/delete-meeting', async (req, res) => {
  const { meeting_id, member_id } = req.body;

  if (!meeting_id || !member_id) {
    return res.status(400).json({ error: 'meeting_id و member_id مطلوبين' });
  }

  // 1. جلب التوكن من قاعدة البيانات
  const getTokenQuery = `
    SELECT access_token FROM video_integrations
    WHERE member_id = ? AND provider = 'zoom'
  `;

  db.query(getTokenQuery, [member_id], async (err, results) => {
    if (err) {
      console.error('❌ Error fetching token:', err);
      return res.status(500).json({ error: 'خطأ في جلب التوكن من قاعدة البيانات' });
    }

    if (results.length === 0) {
      return res.status(404).json({ error: 'لا يوجد توكن لهذا المستخدم' });
    }

    const access_token = results[results.length - 1].access_token;


    try {
      // 2. إرسال طلب الحذف لزوم
      const response = await axios.delete(`https://api.zoom.us/v2/meetings/${meeting_id}`, {
        headers: {
          Authorization: `Bearer ${access_token}`,
          'Content-Type': 'application/json'
        }
      });

      if (response.status === 204) {
        console.log('✅ Zoom meeting deleted');
        return res.json({ success: true, message: 'تم حذف الاجتماع بنجاح' });
      } else {
        return res.status(response.status).json({ error: 'فشل في حذف الاجتماع من زوم' });
      }
    } catch (error) {
      console.error('🔴 Error deleting Zoom meeting:', error.response?.data || error.message);
      return res.status(500).json({ error: 'حدث خطأ أثناء حذف الاجتماع' });
    }
  });
});




// الراوت لجلب meeting_code بواسطة booking_id
router.post('/get-meeting-code-zoom', (req, res) => {
  const { booking_id } = req.body;

  if (!booking_id) {
    return res.status(400).json({ error: 'booking_id مطلوب' });
  }

  const query = `SELECT meeting_code FROM generated_meetings WHERE booking_id = ? LIMIT 1`;

  db.query(query, [booking_id], (err, results) => {
    if (err) {
      console.error('❌ DB query error:', err);
      return res.status(500).json({ error: 'خطأ في جلب بيانات الاجتماع' });
    }

    if (results.length === 0) {
      return res.status(404).json({ error: 'لا يوجد اجتماع لهذا booking_id' });
    }

    res.json({ meeting_code: results[0].meeting_code });
  });
});
////////////////////////////////////////////////////////////////////////////////




// راوت لحذف اجتماع زوم حسب booking_id و member_id
router.post('/delete-meeting-by-booking', (req, res) => {
  const { booking_id, member_id } = req.body;

  if (!booking_id || !member_id) {
    return res.status(400).json({ error: 'booking_id و member_id مطلوبين' });
  }

  // 1. جلب access_token
  const getTokenQuery = `
    SELECT access_token FROM video_integrations
    WHERE member_id = ? AND provider = 'zoom'
  `;

  db.query(getTokenQuery, [member_id], (err, tokenResults) => {
    if (err) {
      console.error('❌ Error fetching token:', err);
      return res.status(500).json({ error: 'خطأ في جلب التوكن من قاعدة البيانات' });
    }

    if (tokenResults.length === 0) {
      return res.status(404).json({ error: 'لا يوجد توكن لهذا المستخدم' });
    }

    const access_token = tokenResults[tokenResults.length - 1].access_token;

    // 2. جلب meeting_code من generated_meetings باستخدام booking_id
    const getMeetingCodeQuery = `
      SELECT meeting_code FROM generated_meetings
      WHERE booking_id = ?
      LIMIT 1
    `;

    db.query(getMeetingCodeQuery, [booking_id], async (err, meetingResults) => {
      if (err) {
        console.error('❌ Error fetching meeting_code:', err);
        return res.status(500).json({ error: 'خطأ في جلب بيانات الاجتماع' });
      }

      if (meetingResults.length === 0) {
        return res.status(404).json({ error: 'لا يوجد اجتماع مرتبط بهذا booking_id' });
      }

      const meeting_code = meetingResults[0].meeting_code;

      try {
        // 3. إرسال طلب الحذف إلى Zoom باستخدام meeting_code كـ meetingId
        const response = await axios.delete(`https://api.zoom.us/v2/meetings/${encodeURIComponent(meeting_code)}`, {
          headers: {
            Authorization: `Bearer ${access_token}`,
            'Content-Type': 'application/json'
          }
        });

        if (response.status === 204) {
          console.log('✅ Zoom meeting deleted');

          // 4. حذف السجل من جدول generated_meetings
          const deleteQuery = `DELETE FROM generated_meetings WHERE booking_id = ?`;
          db.query(deleteQuery, [booking_id], (err) => {
            if (err) {
              console.error('❌ Error deleting DB record:', err);
              // نرجع نجاح الحذف من Zoom حتى لو حذف DB فشل
              return res.status(500).json({ warning: 'تم حذف الاجتماع من زوم لكن فشل حذف السجل من قاعدة البيانات' });
            }

            return res.json({ success: true, message: 'تم حذف الاجتماع من زوم وقاعدة البيانات بنجاح' });
          });

        } else {
          return res.status(response.status).json({ error: 'فشل في حذف الاجتماع من زوم' });
        }

      } catch (error) {
        console.error('🔴 Error deleting Zoom meeting:', error.response?.data || error.message);
        return res.status(500).json({ error: 'حدث خطأ أثناء حذف الاجتماع' });
      }
    });
  });
});





router.post('/delete-meeting-from-database', (req, res) => {
  const { meeting_id } = req.body;

  if (!meeting_id) {
    return res.status(400).json({ error: 'meeting_id مطلوب' });
  }

  const deleteQuery = `
    DELETE FROM meetings
    WHERE meeting_id = ?
  `;

  db.query(deleteQuery, [meeting_id], (err, result) => {
    if (err) {
      console.error('❌ خطأ في حذف الاجتماع:', err);
      return res.status(500).json({ error: 'حدث خطأ أثناء حذف الاجتماع' });
    }

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'لم يتم العثور على اجتماع بهذا الرقم' });
    }

    res.json({ success: true, message: 'تم حذف الاجتماع بنجاح' });
  });
});







/*
// حذف اجتماع من زوم رح احتاجه في اول واجه يعرض فيها الاجتمامعات
async function deleteZoomMeeting(meetingId, accessToken) {
  const response = await fetch(`https://api.zoom.us/v2/meetings/${meetingId}`, {
    method: 'DELETE',
    headers: {
      'Authorization': `Bearer ${accessToken}`,
      'Content-Type': 'application/json'
    }
  });

  if (response.status === 204) {
    console.log("Zoom meeting deleted");
    return true;
  } else {
    const error = await response.json();
    console.error("Zoom error:", error);
    return false;
  }
}*/

module.exports = router;
