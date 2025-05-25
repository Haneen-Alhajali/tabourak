const db = require('../../config/db').promise();

exports.getResponsesByMeeting = async (meetingId) => {
  const [results] = await db.query(`
    SELECT 
      r.user_info_id, 
      cf.label, 
      r.response_text, 
      r.created_at
    FROM custom_field_responses r
    JOIN custom_fields cf ON r.field_id = cf.field_id
    WHERE r.meeting_id = ?
    ORDER BY r.user_info_id, cf.display_order
  `, [meetingId]);

  return results;
};


exports.getResponsesByPageId = async (pageId) => {
  const [results] = await db.query(`
    SELECT 
      u.user_info_id,
      u.first_name,
      u.last_name,
      u.email,
      a.name AS appointment_name,
      m.start_time,
      m.timezone,
      cf.label,
      r.response_text,
      r.created_at
    FROM custom_field_responses r
    JOIN custom_fields cf ON r.field_id = cf.field_id
    JOIN meetings m ON r.meeting_id = m.meeting_id
    JOIN appointments a ON m.appointment_id = a.appointment_id
    JOIN intake_form_user_info u ON m.user_info_id = u.user_info_id
    WHERE a.page_id = ?
    ORDER BY u.user_info_id, cf.display_order
  `, [pageId]);

  return results;
};


exports.getResponsesByMemberId = async (memberId) => {
  const [orgResult] = await db.query(
    `SELECT organization_id FROM members WHERE member_id = ?`,
    [memberId]
  );

  if (!orgResult.length) return [];

  const organizationId = orgResult[0].organization_id;

  const [results] = await db.query(`
    SELECT 
      info.user_info_id,
      info.first_name,
      info.last_name,
      info.email,
      m.start_time,
      m.timezone,
      a.name AS appointment_name,
      cf.label,
      r.response_text,
      r.created_at
    FROM custom_field_responses r
    JOIN custom_fields cf ON r.field_id = cf.field_id
    JOIN meetings m ON r.meeting_id = m.meeting_id
    JOIN intake_form_user_info info ON m.user_info_id = info.user_info_id
    JOIN appointments a ON m.appointment_id = a.appointment_id
    WHERE a.page_id IN (
      SELECT page_id FROM scheduling_pages WHERE organization_id = ?
    )
    AND m.start_time < NOW()
    ORDER BY info.user_info_id, m.start_time, cf.display_order
  `, [organizationId]);

  return results;
};
