// controllers/availabilityController.js
const db = require('../config/db');

// Get user availability (linked to appointments created in step1)
exports.getAvailability = async (req, res) => {
  try {
    console.log('getAvailability called');
    const userId = req.user.id;
    console.log(`User ID: ${userId}`);

    // 1. Get member ID
    console.log('Fetching member ID from database...');
    const [member] = await db.promise().query(
      'SELECT member_id FROM members WHERE user_id = ?',
      [userId]
    );
    
    console.log(`Member query result: ${JSON.stringify(member)}`);
    
    if (!member[0]) {
      console.log('Member not found for user');
      return res.status(404).json({ error: 'Member not found' });
    }
    
    const memberId = member[0].member_id;
    console.log(`Found member ID: ${memberId}`);

    // 2. Get the member's default schedule
    console.log('Fetching member availability schedule...');
    const [schedules] = await db.promise().query(
      `SELECT 
        schedule_id,
        timezone,
        created_at,
        updated_at
      FROM availability_schedules
      WHERE member_id = ? AND is_default = TRUE
      LIMIT 1`,
      [memberId]
    );

    console.log(`Schedule query result: ${JSON.stringify(schedules)}`);

    if (schedules.length === 0) {
      console.log('No availability schedule found for member');
      return res.status(404).json({ error: 'No availability schedule found' });
    }

    const schedule = schedules[0];
    console.log(`Found schedule ID: ${schedule.schedule_id}`);
    
    // 3. Get all time slots for this schedule
    console.log('Fetching time slots for schedule...');
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

    console.log(`Time slots query result: ${JSON.stringify(slots)}`);

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
      if (!dayName) {
        console.log(`Unknown day_of_week: ${slot.day_of_week}`);
        return;
      }
      
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

    console.log('Processed availability:', JSON.stringify(availability));

    res.status(200).json({
      availability,
      scheduleId: schedule.schedule_id,
      timezone: schedule.timezone,
      exists: true,
      createdAt: schedule.created_at,
      updatedAt: schedule.updated_at
    });

  } catch (err) {
    console.error('Error getting availability:', {
      error: err,
      userId: req.user?.id,
      memberId: member?.member_id,
      scheduleId: schedule?.schedule_id
    });
    res.status(500).json({ error: 'Failed to get availability' });
  }
};

// Update existing availability schedule
exports.updateAvailability = async (req, res) => {
  try {
    console.log('updateAvailability called');
    const userId = req.user.id;
    const { availability, scheduleId } = req.body;

    console.log(`Request data - User ID: ${userId}, Schedule ID: ${scheduleId}, Availability: ${JSON.stringify(availability)}`);

    if (!scheduleId) {
      console.log('Schedule ID missing in request');
      return res.status(400).json({ error: 'Schedule ID is required' });
    }

    // 1. Verify the schedule belongs to the user's member record
    console.log('Verifying schedule ownership...');
    const [member] = await db.promise().query(
      `SELECT m.member_id 
       FROM members m
       JOIN availability_schedules s ON m.member_id = s.member_id
       WHERE m.user_id = ? AND s.schedule_id = ?`,
      [userId, scheduleId]
    );
    
    console.log(`Ownership verification result: ${JSON.stringify(member)}`);
    
    if (!member[0]) {
      console.log('User not authorized to update this schedule');
      return res.status(403).json({ error: 'Not authorized to update this schedule' });
    }

    console.log('Starting database transaction...');
    await db.promise().query('START TRANSACTION');

    // 2. Clear existing availability for this schedule
    console.log('Clearing existing availability slots...');
    await db.promise().query(
      'DELETE FROM recurring_availability WHERE schedule_id = ?',
      [scheduleId]
    );

    // 3. Insert new availability slots
    console.log('Preparing to insert new availability slots...');
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
      if (!dbDay) {
        console.log(`Skipping unknown day: ${day}`);
        continue;
      }

      console.log(`Processing day: ${day} (${dbDay})`);
      
      for (const range of timeRanges) {
        const startTime = `${range.start.hour.toString().padStart(2, '0')}:${range.start.minute.toString().padStart(2, '0')}:00`;
        const endTime = `${range.end.hour.toString().padStart(2, '0')}:${range.end.minute.toString().padStart(2, '0')}:00`;

        console.log(`Adding time range: ${startTime} to ${endTime} for ${dbDay}`);
        
        insertPromises.push(
          db.promise().query(
            'INSERT INTO recurring_availability (schedule_id, day_of_week, start_time, end_time, is_available) VALUES (?, ?, ?, ?, ?)',
            [scheduleId, dbDay, startTime, endTime, true]
          )
        );
      }
    }

    console.log(`Executing ${insertPromises.length} insert operations...`);
    await Promise.all(insertPromises);

    // 4. Update schedule timestamp
    console.log('Updating schedule timestamp...');
    await db.promise().query(
      'UPDATE availability_schedules SET updated_at = CURRENT_TIMESTAMP WHERE schedule_id = ?',
      [scheduleId]
    );

    console.log('Committing transaction...');
    await db.promise().query('COMMIT');

    console.log('Availability update successful');
    res.status(200).json({
      success: true,
      message: 'Availability updated successfully',
      scheduleId
    });

  } catch (err) {
    console.error('Error updating availability:', err);
    console.log('Attempting to rollback transaction...');
    await db.promise().query('ROLLBACK');
    res.status(500).json({ 
      error: 'Failed to update availability',
      details: err.message 
    });
  }
};




exports.getAvailabilityForSchedule = async (req, res) => {
  try {
    const { scheduleId } = req.query;
    const userId = req.user.id;

    if (!scheduleId) {
      return res.status(400).json({ error: 'Schedule ID is required' });
    }

    // Verify schedule belongs to user
    const [schedule] = await db.promise().query(
      `SELECT s.schedule_id 
       FROM availability_schedules s
       JOIN members m ON s.member_id = m.member_id
       WHERE m.user_id = ? AND s.schedule_id = ?`,
      [userId, scheduleId]
    );
    
    if (!schedule[0]) {
      return res.status(403).json({ error: 'Not authorized to access this schedule' });
    }

    // Get all time slots for this schedule
    const [slots] = await db.promise().query(
      `SELECT 
        day_of_week, 
        TIME_FORMAT(start_time, '%H:%i') as start_time,
        TIME_FORMAT(end_time, '%H:%i') as end_time
      FROM recurring_availability
      WHERE schedule_id = ?
      ORDER BY day_of_week, start_time`,
      [scheduleId]
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

    // Ensure all days are present in the response
    Object.values(dayMap).forEach(day => {
      if (!availability[day]) {
        availability[day] = [];
      }
    });

    res.status(200).json({ availability });
  } catch (err) {
    console.error('Error getting schedule availability:', err);
    res.status(500).json({ error: 'Failed to get schedule availability' });
  }
};










// // controllers\availabilityController.js
// const db = require('../config/db');

// // Get user availability (linked to appointments created in step1)
// exports.getAvailability = async (req, res) => {
//   try {
//     console.log('getAvailability called'); // Debug log
//     const userId = req.user.id;
//     console.log(`User ID: ${userId}`); // Debug log

//     // 1. Get member ID
//     console.log('Fetching member ID from database...'); // Debug log
//     const [member] = await db.promise().query(
//       'SELECT member_id FROM members WHERE user_id = ?',
//       [userId]
//     );
    
//     console.log(`Member query result: ${JSON.stringify(member)}`); // Debug log
    
//     if (!member[0]) {
//       console.log('Member not found for user'); // Debug log
//       return res.status(404).json({ error: 'Member not found' });
//     }
    
//     const memberId = member[0].member_id;
//     console.log(`Found member ID: ${memberId}`); // Debug log

//     // 2. Get the schedule linked to the member's appointments
//     console.log('Fetching schedule linked to member appointments...'); // Debug log
//     const [schedules] = await db.promise().query(
//       `SELECT 
//         a.schedule_id,
//         s.timezone,
//         s.created_at,
//         s.updated_at
//       FROM appointments a
//       JOIN availability_schedules s ON a.schedule_id = s.schedule_id
//       WHERE a.member_id = ?
//       GROUP BY a.schedule_id
//       LIMIT 1`,
//       [memberId]
//     );

//     console.log(`Schedule query result: ${JSON.stringify(schedules)}`); // Debug log

//     if (schedules.length === 0) {
//       console.log('No availability schedule found for member'); // Debug log
//       return res.status(404).json({ error: 'No availability schedule found' });
//     }

//     const schedule = schedules[0];
//     console.log(`Found schedule ID: ${schedule.schedule_id}`); // Debug log
    
//     // 3. Get all time slots for this schedule
//     console.log('Fetching time slots for schedule...'); // Debug log
//     const [slots] = await db.promise().query(
//       `SELECT 
//         day_of_week, 
//         TIME_FORMAT(start_time, '%H:%i') as start_time,
//         TIME_FORMAT(end_time, '%H:%i') as end_time
//       FROM recurring_availability
//       WHERE schedule_id = ?
//       ORDER BY day_of_week, start_time`,
//       [schedule.schedule_id]
//     );

//     console.log(`Time slots query result: ${JSON.stringify(slots)}`); // Debug log

//     const availability = {};
//     const dayMap = {
//       "sunday": "Sunday",
//       "monday": "Monday",
//       "tuesday": "Tuesday",
//       "wednesday": "Wednesday",
//       "thursday": "Thursday",
//       "friday": "Friday",
//       "saturday": "Saturday"
//     };

//     slots.forEach(slot => {
//       const dayName = dayMap[slot.day_of_week];
//       if (!dayName) {
//         console.log(`Unknown day_of_week: ${slot.day_of_week}`); // Debug log
//         return;
//       }
      
//       if (!availability[dayName]) {
//         availability[dayName] = [];
//       }

//       const [startHour, startMinute] = slot.start_time.split(':').map(Number);
//       const [endHour, endMinute] = slot.end_time.split(':').map(Number);
      
//       availability[dayName].push({
//         start: { hour: startHour, minute: startMinute },
//         end: { hour: endHour, minute: endMinute }
//       });
//     });

//     console.log('Processed availability:', JSON.stringify(availability)); // Debug log

//     res.status(200).json({
//       availability,
//       scheduleId: schedule.schedule_id,
//       timezone: schedule.timezone,
//       exists: true,
//       createdAt: schedule.created_at,
//       updatedAt: schedule.updated_at
//     });

//   } catch (err) {
//     console.error('Error getting availability:', {
//       error: err,
//       userId: userId,
//       memberId: memberId,
//       scheduleId: schedule?.schedule_id
//     });
//     res.status(500).json({ error: 'Failed to get availability' });
//   }
// };

// // Update existing availability schedule
// exports.updateAvailability = async (req, res) => {
//   try {
//     console.log('updateAvailability called'); // Debug log
//     const userId = req.user.id;
//     const { availability, scheduleId } = req.body;

//     console.log(`Request data - User ID: ${userId}, Schedule ID: ${scheduleId}, Availability: ${JSON.stringify(availability)}`); // Debug log

//     if (!scheduleId) {
//       console.log('Schedule ID missing in request'); // Debug log
//       return res.status(400).json({ error: 'Schedule ID is required' });
//     }

//     // 1. Verify the schedule belongs to the user's member record
//     console.log('Verifying schedule ownership...'); // Debug log
//     const [member] = await db.promise().query(
//       `SELECT m.member_id 
//        FROM members m
//        JOIN availability_schedules s ON m.member_id = s.member_id
//        WHERE m.user_id = ? AND s.schedule_id = ?`,
//       [userId, scheduleId]
//     );
    
//     console.log(`Ownership verification result: ${JSON.stringify(member)}`); // Debug log
    
//     if (!member[0]) {
//       console.log('User not authorized to update this schedule'); // Debug log
//       return res.status(403).json({ error: 'Not authorized to update this schedule' });
//     }

//     console.log('Starting database transaction...'); // Debug log
//     await db.promise().query('START TRANSACTION');

//     // 2. Clear existing availability for this schedule
//     console.log('Clearing existing availability slots...'); // Debug log
//     await db.promise().query(
//       'DELETE FROM recurring_availability WHERE schedule_id = ?',
//       [scheduleId]
//     );

//     // 3. Insert new availability slots
//     console.log('Preparing to insert new availability slots...'); // Debug log
//     const dayMap = {
//       "Sunday": "sunday",
//       "Monday": "monday",
//       "Tuesday": "tuesday",
//       "Wednesday": "wednesday",
//       "Thursday": "thursday",
//       "Friday": "friday",
//       "Saturday": "saturday"
//     };

//     const insertPromises = [];
    
//     for (const [day, timeRanges] of Object.entries(availability)) {
//       const dbDay = dayMap[day];
//       if (!dbDay) {
//         console.log(`Skipping unknown day: ${day}`); // Debug log
//         continue;
//       }

//       console.log(`Processing day: ${day} (${dbDay})`); // Debug log
      
//       for (const range of timeRanges) {
//         const startTime = `${range.start.hour.toString().padStart(2, '0')}:${range.start.minute.toString().padStart(2, '0')}:00`;
//         const endTime = `${range.end.hour.toString().padStart(2, '0')}:${range.end.minute.toString().padStart(2, '0')}:00`;

//         console.log(`Adding time range: ${startTime} to ${endTime} for ${dbDay}`); // Debug log
        
//         insertPromises.push(
//           db.promise().query(
//             'INSERT INTO recurring_availability (schedule_id, day_of_week, start_time, end_time, is_available) VALUES (?, ?, ?, ?, ?)',
//             [scheduleId, dbDay, startTime, endTime, true]
//           )
//         );
//       }
//     }

//     console.log(`Executing ${insertPromises.length} insert operations...`); // Debug log
//     await Promise.all(insertPromises);

//     // 4. Update schedule timestamp
//     console.log('Updating schedule timestamp...'); // Debug log
//     await db.promise().query(
//       'UPDATE availability_schedules SET updated_at = CURRENT_TIMESTAMP WHERE schedule_id = ?',
//       [scheduleId]
//     );

//     console.log('Committing transaction...'); // Debug log
//     await db.promise().query('COMMIT');

//     console.log('Availability update successful'); // Debug log
//     res.status(200).json({
//       success: true,
//       message: 'Availability updated successfully',
//       scheduleId
//     });

//   } catch (err) {
//     console.error('Error updating availability:', err);
//     console.log('Attempting to rollback transaction...'); // Debug log
//     await db.promise().query('ROLLBACK');
//     res.status(500).json({ 
//       error: 'Failed to update availability',
//       details: err.message 
//     });
//   }
// };
