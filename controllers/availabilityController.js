// controllers\availabilityController.js
const db = require('../config/db');

// Save or update user availability
exports.saveAvailability = async (req, res) => {
  try {
    const userId = req.user.id;
    const { availability, timezone = 'UTC', scheduleId: clientScheduleId } = req.body;

    // Validate input
    if (!availability || typeof availability !== 'object') {
      return res.status(400).json({ error: 'Invalid availability data' });
    }

    await db.promise().query('START TRANSACTION');

    // 1. Check for existing schedule
    let scheduleId = clientScheduleId;
    let action = 'created';
    
    if (scheduleId) {
      // Verify the schedule belongs to the user
      const [existing] = await db.promise().query(
        'SELECT 1 FROM availability_schedules WHERE schedule_id = ? AND user_id = ?',
        [scheduleId, userId]
      );
      
      if (existing.length === 0) {
        await db.promise().query('ROLLBACK');
        return res.status(403).json({ error: 'Not authorized to update this schedule' });
      }

      action = 'updated';
      
      // Update existing schedule
      await db.promise().query(
        'UPDATE availability_schedules SET timezone = ?, updated_at = CURRENT_TIMESTAMP WHERE schedule_id = ?',
        [timezone, scheduleId]
      );
      
      // Clear existing availability for this schedule
      await db.promise().query(
        'DELETE FROM recurring_availability WHERE schedule_id = ?',
        [scheduleId]
      );
    } else {
      // Create new schedule
      const [result] = await db.promise().query(
        'INSERT INTO availability_schedules (user_id, name, timezone, is_default) VALUES (?, ?, ?, ?)',
        [userId, 'Default Availability', timezone, true]
      );
      scheduleId = result.insertId;
    }

    // 2. Insert new availability slots
    const dayMap = {
      "Sunday": "sunday",
      "Monday": "monday",
      "Tuesday": "tuesday",
      "Wednesday": "wednesday",
      "Thursday": "thursday",
      "Friday": "friday",
      "Saturday": "saturday"
    };

    const insertPromises = [];
    
    for (const [day, timeRanges] of Object.entries(availability)) {
      const dbDay = dayMap[day];
      if (!dbDay) continue;

      for (const range of timeRanges) {
        const startTime = `${range.start.hour.toString().padStart(2, '0')}:${range.start.minute.toString().padStart(2, '0')}:00`;
        const endTime = `${range.end.hour.toString().padStart(2, '0')}:${range.end.minute.toString().padStart(2, '0')}:00`;

        insertPromises.push(
          db.promise().query(
            'INSERT INTO recurring_availability (schedule_id, day_of_week, start_time, end_time, is_available) VALUES (?, ?, ?, ?, ?)',
            [scheduleId, dbDay, startTime, endTime, true]
          )
        );
      }
    }

    await Promise.all(insertPromises);
    await db.promise().query('COMMIT');

    res.status(200).json({
      success: true,
      message: `Availability ${action} successfully`,
      scheduleId,
      action
    });

  } catch (err) {
    await db.promise().query('ROLLBACK');
    console.error('Error saving availability:', err);
    res.status(500).json({ 
      error: 'Failed to save availability',
      details: err.message 
    });
  }
};

// Get user availability
exports.getAvailability = async (req, res) => {
  try {
    const userId = req.user.id;

    // Get default schedule with availability
    const [schedules] = await db.promise().query(
      `SELECT 
        s.schedule_id, 
        s.timezone,
        s.created_at,
        s.updated_at
      FROM availability_schedules s
      WHERE s.user_id = ? AND s.is_default = TRUE
      ORDER BY s.schedule_id DESC
      LIMIT 1`,
      [userId]
    );

    if (schedules.length === 0) {
      return res.status(200).json({ 
        availability: {},
        exists: false
      });
    }

    const schedule = schedules[0];
    
    // Get all time slots for this schedule
    const [slots] = await db.promise().query(
      `SELECT 
        day_of_week, 
        TIME_FORMAT(start_time, '%H:%i') as start_time,
        TIME_FORMAT(end_time, '%H:%i') as end_time
      FROM recurring_availability
      WHERE schedule_id = ?
      ORDER BY day_of_week, start_time`,
      [schedule.schedule_id]
    );

    const availability = {};
    const dayMap = {
      "sunday": "Sunday",
      "monday": "Monday",
      "tuesday": "Tuesday",
      "wednesday": "Wednesday",
      "thursday": "Thursday",
      "friday": "Friday",
      "saturday": "Saturday"
    };

    slots.forEach(slot => {
      const dayName = dayMap[slot.day_of_week];
      if (!dayName) return;
      
      if (!availability[dayName]) {
        availability[dayName] = [];
      }

      const [startHour, startMinute] = slot.start_time.split(':').map(Number);
      const [endHour, endMinute] = slot.end_time.split(':').map(Number);
      
      availability[dayName].push({
        start: { hour: startHour, minute: startMinute },
        end: { hour: endHour, minute: endMinute }
      });
    });

    res.status(200).json({
      availability,
      scheduleId: schedule.schedule_id,
      timezone: schedule.timezone,
      exists: true,
      createdAt: schedule.created_at,
      updatedAt: schedule.updated_at
    });

  } catch (err) {
    console.error('Error getting availability:', err);
    res.status(500).json({ error: 'Failed to get availability' });
  }
};