const db = require('../config/db');

exports.getMeetingsByStaff = (req, res) => {
  const { staff_id } = req.params;

  const query = `
    SELECT 
      m.meeting_id,
      m.start_time,
      m.end_time,
      DATE(m.start_time) AS meeting_date,
      a.name AS appointment_name,
      a.meeting_type,
      a.video_provider,
      a.meeting_phone,
      a.location,
      u.user_info_id, -- ✅ هنا
      u.first_name,
      u.last_name,
      u.email,
      g.start_url,
      g.meeting_code 
    FROM meetings m
    JOIN appointments a ON m.appointment_id = a.appointment_id
    JOIN intake_form_user_info u ON m.user_info_id = u.user_info_id
    LEFT JOIN generated_meetings g ON m.meeting_id = g.booking_id
    WHERE m.staff_id = ?
    ORDER BY m.start_time DESC
  `;

  db.query(query, [staff_id], (err, results) => {
    if (err) {
      console.error('Error fetching meetings:', err);
      return res.status(500).json({ error: 'Database error' });
    }

    const meetings = results.map(meeting => {
      let meeting_detail = null;

      if (meeting.meeting_type === 'in_person') {
        meeting_detail = meeting.location;
      } else if (meeting.meeting_type === 'phone_call') {
        meeting_detail = meeting.meeting_phone;
      } else if (meeting.meeting_type === 'video_call') {
        meeting_detail = meeting.start_url;
      }

      return {
        meeting_id: meeting.meeting_id,
        appointment_name: meeting.appointment_name,
        start_time: meeting.start_time,
        end_time: meeting.end_time,
        date: meeting.meeting_date,
        meeting_type: meeting.meeting_type,
        user: {
          id: meeting.user_info_id, // ✅ هنا
          name: `${meeting.first_name} ${meeting.last_name}`,
          email: meeting.email
        },
        meeting_detail: meeting_detail,
        meeting_code: meeting.meeting_code || null 
      };
    });

    res.json(meetings);
  });
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
    ORDER BY info.user_info_id, m.start_time, cf.display_order
  `, [organizationId]);

  return results;
};