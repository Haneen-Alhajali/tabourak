//C:\Users\User\Desktop\Flutter BackEnd\tabourak-backend\models\calenderModel.js
const db = require('../../config/db');

const saveGoogleCalendarIntegration = (userId, email, accessToken, refreshToken, callback) => {
  const sql = `
    INSERT INTO calendar_integrations (
      user_id, provider, account_email, access_token, refresh_token, is_active, is_connected
    ) VALUES (?, 'google', ?, ?, ?, true, true)
    ON DUPLICATE KEY UPDATE 
      access_token = VALUES(access_token),
      refresh_token = VALUES(refresh_token),
      is_connected = true,
      updated_at = CURRENT_TIMESTAMP
  `;

  db.query(sql, [userId, email, accessToken, refreshToken], callback);
};

module.exports = { saveGoogleCalendarIntegration };
