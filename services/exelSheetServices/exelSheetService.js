const db = require('../../config/db').promise();

exports.getResponsesByMeeting = async (meetingId) => {
  const [results] = await db.query(`
    SELECT 
      r.user_id, 
      cf.label, 
      r.response_text, 
      r.created_at
    FROM custom_field_responses r
    JOIN custom_fields cf ON r.field_id = cf.field_id
    WHERE r.meeting_id = ?
    ORDER BY r.user_id, cf.display_order
  `, [meetingId]);

  return results;
};
