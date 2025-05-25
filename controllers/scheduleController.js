// controllers/scheduleController.js
const db = require('../config/db');

// Correct availability (Sunday-Thursday, 9am-5pm)
const DEFAULT_AVAILABILITY = {
  "Sunday": [{ start: { hour: 9, minute: 0 }, end: { hour: 17, minute: 0 } }],
  "Monday": [{ start: { hour: 9, minute: 0 }, end: { hour: 17, minute: 0 } }],
  "Tuesday": [{ start: { hour: 9, minute: 0 }, end: { hour: 17, minute: 0 } }],
  "Wednesday": [{ start: { hour: 9, minute: 0 }, end: { hour: 17, minute: 0 } }],
  "Thursday": [{ start: { hour: 9, minute: 0 }, end: { hour: 17, minute: 0 } }]
  // Friday-Saturday excluded as weekends
};

// Get all schedules for a member
exports.getMemberSchedules = async (req, res) => {
  try {
    const userId = req.user.id;

    // Get member ID
    const [member] = await db.promise().query(
      'SELECT member_id FROM members WHERE user_id = ?',
      [userId]
    );
    
    if (!member[0]) {
      return res.status(404).json({ error: 'Member not found' });
    }

    // Get all schedules for this member
    const [schedules] = await db.promise().query(
      `SELECT 
        schedule_id as id,
        name,
        timezone,
        is_default as isDefault,
        created_at as createdAt,
        updated_at as updatedAt
      FROM availability_schedules
      WHERE member_id = ?
      ORDER BY is_default DESC, name ASC`,
      [member[0].member_id]
    );

    res.status(200).json(schedules);
  } catch (err) {
    console.error('Error getting schedules:', err);
    res.status(500).json({ error: 'Failed to get schedules' });
  }
};

// Create a new schedule
// exports.createSchedule = async (req, res) => {
//   try {
//     const userId = req.user.id;
//     const { name, timezone, isDefault } = req.body;

//     // Validate input
//     if (!name || !timezone) {
//       return res.status(400).json({ error: 'Name and timezone are required' });
//     }

//     // Get member ID
//     const [member] = await db.promise().query(
//       'SELECT member_id FROM members WHERE user_id = ?',
//       [userId]
//     );
    
//     if (!member[0]) {
//       return res.status(404).json({ error: 'Member not found' });
//     }

//     await db.promise().query('START TRANSACTION');

//     // If this is being set as default, first unset any existing default
//     if (isDefault) {
//       await db.promise().query(
//         'UPDATE availability_schedules SET is_default = FALSE WHERE member_id = ?',
//         [member[0].member_id]
//       );
//     }

//     // Create new schedule
//     const [result] = await db.promise().query(
//       'INSERT INTO availability_schedules (member_id, name, timezone, is_default) VALUES (?, ?, ?, ?)',
//       [member[0].member_id, name, timezone, isDefault || false]
//     );

//     await db.promise().query('COMMIT');

//     res.status(201).json({
//       id: result.insertId,
//       name,
//       timezone,
//       isDefault: isDefault || false,
//       message: 'Schedule created successfully'
//     });
//   } catch (err) {
//     await db.promise().query('ROLLBACK');
//     console.error('Error creating schedule:', err);
//     res.status(500).json({ error: 'Failed to create schedule' });
//   }
// };

// Create a new schedule
exports.createSchedule = async (req, res) => {
  try {
    const userId = req.user.id;
    const { name, timezone, isDefault } = req.body;

    // Validate input
    if (!name || !timezone) {
      return res.status(400).json({ error: 'Name and timezone are required' });
    }

    // Get member ID
    const [member] = await db.promise().query(
      'SELECT member_id FROM members WHERE user_id = ?',
      [userId]
    );
    
    if (!member[0]) {
      return res.status(404).json({ error: 'Member not found' });
    }

    const memberId = member[0].member_id;

    await db.promise().query('START TRANSACTION');

    // If this is being set as default, first unset any existing default
    if (isDefault) {
      await db.promise().query(
        'UPDATE availability_schedules SET is_default = FALSE WHERE member_id = ?',
        [memberId]
      );
    }

    // Create new schedule
    const [result] = await db.promise().query(
      'INSERT INTO availability_schedules (member_id, name, timezone, is_default) VALUES (?, ?, ?, ?)',
      [memberId, name, timezone, isDefault || false]
    );

    const scheduleId = result.insertId;

    // Add default recurring availability slots (excluding Friday-Saturday)
    const dayMap = {
      "Sunday": "sunday",
      "Monday": "monday", 
      "Tuesday": "tuesday",
      "Wednesday": "wednesday",
      "Thursday": "thursday"
    };

    // Assuming DEFAULT_AVAILABILITY is defined somewhere in your code
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

    await db.promise().query('COMMIT');

    res.status(201).json({
      id: scheduleId,
      name,
      timezone,
      isDefault: isDefault || false,
      message: 'Schedule created successfully with default availability slots'
    });
  } catch (err) {
    await db.promise().query('ROLLBACK');
    console.error('Error creating schedule:', err);
    res.status(500).json({ error: 'Failed to create schedule' });
  }
};



// Update a schedule
exports.updateSchedule = async (req, res) => {
  try {
    const userId = req.user.id;
    const scheduleId = req.params.id;
    const { name, timezone, isDefault } = req.body;

    // Validate input
    if (!name || !timezone) {
      return res.status(400).json({ error: 'Name and timezone are required' });
    }

    // Verify schedule ownership
    const [schedule] = await db.promise().query(
      `SELECT s.schedule_id 
       FROM availability_schedules s
       JOIN members m ON s.member_id = m.member_id
       WHERE m.user_id = ? AND s.schedule_id = ?`,
      [userId, scheduleId]
    );
    
    if (!schedule[0]) {
      return res.status(403).json({ error: 'Not authorized to update this schedule' });
    }

    await db.promise().query('START TRANSACTION');

    // If this is being set as default, first unset any existing default
    if (isDefault) {
      await db.promise().query(
        'UPDATE availability_schedules SET is_default = FALSE WHERE member_id = (SELECT member_id FROM members WHERE user_id = ?)',
        [userId]
      );
    }

    // Update schedule
    await db.promise().query(
      'UPDATE availability_schedules SET name = ?, timezone = ?, is_default = ?, updated_at = CURRENT_TIMESTAMP WHERE schedule_id = ?',
      [name, timezone, isDefault || false, scheduleId]
    );

    await db.promise().query('COMMIT');

    res.status(200).json({
      id: scheduleId,
      name,
      timezone,
      isDefault: isDefault || false,
      message: 'Schedule updated successfully'
    });
  } catch (err) {
    await db.promise().query('ROLLBACK');
    console.error('Error updating schedule:', err);
    res.status(500).json({ error: 'Failed to update schedule' });
  }
};

// Delete a schedule
exports.deleteSchedule = async (req, res) => {
  try {
    const userId = req.user.id;
    const scheduleId = req.params.id;

    // Verify schedule ownership and check if it's default
    const [schedule] = await db.promise().query(
      `SELECT s.schedule_id, s.is_default 
       FROM availability_schedules s
       JOIN members m ON s.member_id = m.member_id
       WHERE m.user_id = ? AND s.schedule_id = ?`,
      [userId, scheduleId]
    );
    
    if (!schedule[0]) {
      return res.status(403).json({ error: 'Not authorized to delete this schedule' });
    }

    if (schedule[0].is_default) {
      return res.status(400).json({ error: 'Cannot delete default schedule' });
    }

    // Check if schedule is in use by any appointments
    const [appointments] = await db.promise().query(
      'SELECT appointment_id FROM appointments WHERE schedule_id = ? LIMIT 1',
      [scheduleId]
    );

    if (appointments.length > 0) {
      return res.status(400).json({ 
        error: 'Cannot delete schedule - it is being used by one or more appointment types' 
      });
    }

    await db.promise().query('START TRANSACTION');

    // Delete the schedule (cascading deletes will handle related availability entries)
    await db.promise().query(
      'DELETE FROM availability_schedules WHERE schedule_id = ?',
      [scheduleId]
    );

    await db.promise().query('COMMIT');

    res.status(200).json({
      message: 'Schedule deleted successfully'
    });
  } catch (err) {
    await db.promise().query('ROLLBACK');
    console.error('Error deleting schedule:', err);
    res.status(500).json({ error: 'Failed to delete schedule' });
  }
};

// Get timezone options
exports.getTimezoneOptions = async (req, res) => {
  try {
    // This is a simplified list - in production you might want to use a more complete list
    const timezones = [
      { id: 'Asia/Hebron', name: 'Asia / Hebron' },
      { id: 'America/New_York', name: 'America / New York' },
      { id: 'Europe/London', name: 'Europe / London' },
      { id: 'Asia/Tokyo', name: 'Asia / Tokyo' },
      { id: 'Australia/Sydney', name: 'Australia / Sydney' },
      { id: 'Africa/Cairo', name: 'Africa / Cairo' },
      { id: 'Asia/Dubai', name: 'Asia / Dubai' },
      { id: 'Europe/Paris', name: 'Europe / Paris' },
      { id: 'America/Los_Angeles', name: 'America / Los Angeles' },
      { id: 'America/Chicago', name: 'America / Chicago' }
    ];

    // Get current time for each timezone
    const timezonesWithTime = timezones.map(tz => ({
      ...tz,
      currentTime: new Date().toLocaleTimeString('en-US', {
        timeZone: tz.id,
        hour: '2-digit',
        minute: '2-digit'
      })
    }));

    res.status(200).json(timezonesWithTime);
  } catch (err) {
    console.error('Error getting timezone options:', err);
    res.status(500).json({ error: 'Failed to get timezone options' });
  }
};