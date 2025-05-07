// controllers\appointmentController.js
const db = require('../config/db');
const crypto = require('crypto');

// Correct availability (Sunday-Thursday, 9am-5pm)
const DEFAULT_AVAILABILITY = {
  "Sunday": [{ start: { hour: 9, minute: 0 }, end: { hour: 17, minute: 0 } }],
  "Monday": [{ start: { hour: 9, minute: 0 }, end: { hour: 17, minute: 0 } }],
  "Tuesday": [{ start: { hour: 9, minute: 0 }, end: { hour: 17, minute: 0 } }],
  "Wednesday": [{ start: { hour: 9, minute: 0 }, end: { hour: 17, minute: 0 } }],
  "Thursday": [{ start: { hour: 9, minute: 0 }, end: { hour: 17, minute: 0 } }]
  // Friday-Saturday excluded as weekends
};

// Helper function to get default name based on meeting type
const getDefaultAppointmentName = (meetingType) => {
  switch(meetingType) {
    case 'in_person': return 'In-Person Meeting';
    case 'video_call': return 'Web Conference';
    case 'phone_call': return 'Phone Call';
    default: return 'Meeting';
  }
};

exports.handleAppointments = async (req, res) => {
  try {
    if (!req.user?.id) {
      return res.status(401).json({ error: 'Unauthorized' });
    }

    // Get member and organization info
    const [member] = await db.promise().query(
      `SELECT m.member_id, m.organization_id 
       FROM members m
       WHERE m.user_id = ?`,
      [req.user.id]
    );

    let memberId, organizationId;
    
    if (member.length > 0) {
      memberId = member[0].member_id;
      organizationId = member[0].organization_id;
    } else {
      // Create new organization if none exists
      const [orgResult] = await db.promise().query(
        'INSERT INTO organizations (name) VALUES (?)',
        [`${req.user.name}'s Organization`]
      );
      organizationId = orgResult.insertId;
      
      // Add user as owner
      const [memberResult] = await db.promise().query(
        'INSERT INTO members (user_id, organization_id, role) VALUES (?, ?, ?)',
        [req.user.id, organizationId, 'owner']
      );
      memberId = memberResult.insertId;
    }

    const appointments = req.body.appointments || [];
    const results = [];

    await db.promise().query('START TRANSACTION');

    // Get all existing appointments for this member
    const [existingAppointments] = await db.promise().query(
      'SELECT appointment_id, meeting_type FROM appointments WHERE member_id = ?',
      [memberId]
    );

    // Create map of existing meeting types
    const existingMeetingTypes = new Set(existingAppointments.map(a => a.meeting_type));

    // Check for existing default availability schedule
    const [existingSchedules] = await db.promise().query(
      'SELECT schedule_id FROM availability_schedules WHERE member_id = ? AND is_default = TRUE',
      [memberId]
    );

    let scheduleId;
    if (existingSchedules.length > 0) {
      // Use existing default schedule
      scheduleId = existingSchedules[0].schedule_id;
    } else {
      // Create new default availability schedule
      const [scheduleResult] = await db.promise().query(
        'INSERT INTO availability_schedules (member_id, name, timezone, is_default) VALUES (?, ?, ?, ?)',
        [memberId, 'Default Availability', 'UTC', true]
      );
      scheduleId = scheduleResult.insertId;
      
      // Insert default availability slots (excluding Friday-Saturday)
      const dayMap = {
        "Sunday": "sunday",
        "Monday": "monday", 
        "Tuesday": "tuesday",
        "Wednesday": "wednesday",
        "Thursday": "thursday"
      };

      for (const [day, slots] of Object.entries(DEFAULT_AVAILABILITY)) {
        for (const slot of slots) {
          await db.promise().query(
            'INSERT INTO recurring_availability (schedule_id, day_of_week, start_time, end_time) VALUES (?, ?, ?, ?)',
            [
              scheduleId,
              dayMap[day],
              `${slot.start.hour.toString().padStart(2, '0')}:${slot.start.minute.toString().padStart(2, '0')}:00`,
              `${slot.end.hour.toString().padStart(2, '0')}:${slot.end.minute.toString().padStart(2, '0')}:00`
            ]
          );
        }
      }
    }

    // First deactivate any existing appointments that aren't in the new selection
    const newMeetingTypes = new Set(appointments.map(a => a.meeting_type));
    const typesToDeactivate = [...existingMeetingTypes].filter(type => !newMeetingTypes.has(type));
    
    if (typesToDeactivate.length > 0) {
      await db.promise().query(
        'UPDATE appointments SET is_active = FALSE WHERE member_id = ? AND meeting_type IN (?)',
        [memberId, typesToDeactivate]
      );
    }

    for (const appt of appointments) {
      // Check if this meeting type already exists
      const existingAppt = existingAppointments.find(a => a.meeting_type === appt.meeting_type);
      
      if (existingAppt) {
        // Update existing appointment
        await db.promise().query(
          `UPDATE appointments SET
            name = ?,
            duration_minutes = ?,
            is_active = TRUE,
            updated_at = CURRENT_TIMESTAMP
          WHERE appointment_id = ?`,
          [
            appt.name || getDefaultAppointmentName(appt.meeting_type),
            appt.duration_minutes || (appt.meeting_type === 'phone_call' ? 30 : 60),
            existingAppt.appointment_id
          ]
        );
        
        results.push({
          appointment_id: existingAppt.appointment_id,
          action: 'updated'
        });
      } else {
        // Create new appointment
        const slug = crypto.randomBytes(4).toString('hex');
        const [apptResult] = await db.promise().query(
          `INSERT INTO appointments (
            organization_id, member_id, schedule_id, name, description,
            duration_minutes, meeting_type, location, video_provider, is_active,
            slug, page_title, page_color_primary
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
          [
            organizationId,
            memberId,
            scheduleId,
            appt.name || getDefaultAppointmentName(appt.meeting_type),
            appt.description || '',
            appt.duration_minutes || (appt.meeting_type === 'phone_call' ? 30 : 60),
            appt.meeting_type,
            appt.meeting_type === 'in_person' ? (appt.location || 'Your Office') : null,
            appt.meeting_type === 'video_call' ? (appt.video_provider || 'zoom') : null,
            true,
            slug,
            appt.page_title || `Meet with ${req.user.name}`,
            appt.page_color_primary || '#1C8B97'
          ]
        );
        
        results.push({ 
          appointment_id: apptResult.insertId,
          action: 'created' 
        });
      }
    }

    await db.promise().query('COMMIT');
    
    res.status(200).json({
      success: true,
      message: 'Appointments processed successfully',
      results
    });

  } catch (err) {
    await db.promise().query('ROLLBACK');
    console.error('Error handling appointments:', err);
    res.status(500).json({ 
      error: 'Failed to process appointments',
      details: err.message 
    });
  }
};
exports.getUserAppointments = async (req, res) => {
  try {
    const [member] = await db.promise().query(
      'SELECT member_id FROM members WHERE user_id = ?',
      [req.user.id]
    );

    if (!member[0]) return res.json([]);

    const [appointments] = await db.promise().query(
      `SELECT 
        appointment_id,
        name,
        description,
        duration_minutes as duration,
        meeting_type,
        is_active,
        page_color_primary as color_hex
      FROM appointments WHERE member_id = ?`,
      [member[0].member_id]
    );

    res.json(appointments);
  } catch (err) {
    console.error('Error getting appointments:', err);
    res.status(500).json({ error: 'Failed to get appointments' });
  }
};
