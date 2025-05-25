// controllers/dateSpecificAvailabilityController.js
const db = require('../config/db');

// Get all date-specific availability for a schedule
exports.getDateSpecificAvailability = async (req, res) => {
  try {
    console.log('🔍 [getDateSpecificAvailability] Starting to fetch date-specific availability...');
    const { scheduleId } = req.query;
    const userId = req.user.id;

    console.log(`📋 [getDateSpecificAvailability] Received scheduleId: ${scheduleId}, userId: ${userId}`);

    if (!scheduleId || isNaN(parseInt(scheduleId))) {
      console.error('❌ [getDateSpecificAvailability] Invalid schedule ID');
      return res.status(400).json({ error: 'Invalid schedule ID' });
    }

    // Verify schedule belongs to user
    console.log('🔐 [getDateSpecificAvailability] Verifying schedule ownership...');
    const [schedule] = await db.promise().query(
      `SELECT s.schedule_id 
       FROM availability_schedules s
       JOIN members m ON s.member_id = m.member_id
       WHERE m.user_id = ? AND s.schedule_id = ?`,
      [userId, scheduleId]
    );
    
    if (!schedule[0]) {
      console.error('🚫 [getDateSpecificAvailability] Not authorized to access this schedule');
      return res.status(403).json({ error: 'Not authorized to access this schedule' });
    }

    // Get all date-specific availability
    console.log('📅 [getDateSpecificAvailability] Fetching specific dates from database...');
    const [specificDates] = await db.promise().query(
      `SELECT 
        specific_id as id,
        DATE_FORMAT(specific_date, '%Y-%m-%d') as dateStr,
        TIME_FORMAT(start_time, '%H:%i') as startTime,
        TIME_FORMAT(end_time, '%H:%i') as endTime,
        is_available as isAvailable,
        notes
      FROM date_specific_availability
      WHERE schedule_id = ?
      ORDER BY specific_date ASC`,
      [scheduleId]
    );

    console.log(`✅ [getDateSpecificAvailability] Found ${specificDates.length} date-specific entries`);

    // Convert to frontend format
    console.log('🔄 [getDateSpecificAvailability] Converting to frontend format...');
    const availability = {};
    specificDates.forEach(date => {
      if (!availability[date.dateStr]) {
        availability[date.dateStr] = [];
      }
      
      if (date.startTime && date.endTime) {
        const [startHour, startMinute] = date.startTime.split(':').map(Number);
        const [endHour, endMinute] = date.endTime.split(':').map(Number);
        
        availability[date.dateStr].push({
          start: { hour: startHour, minute: startMinute },
          end: { hour: endHour, minute: endMinute }
        });
      }
    });

    console.log('🎉 [getDateSpecificAvailability] Successfully processed request');
    res.status(200).json({ 
      availability: availability // Ensure this is a direct map of date strings to arrays
    });

  } catch (err) {
    console.error('❌ [getDateSpecificAvailability] Error getting date-specific availability:', err);
    res.status(500).json({ error: 'Failed to get date-specific availability' });
  }
};

// Update date-specific availability with delete support
exports.updateDateSpecificAvailability = async (req, res) => {
  try {
    console.log('🔄 [updateDateSpecificAvailability] Starting to update date-specific availability...');
    const userId = req.user.id;
    const { scheduleId, dateSpecificHours = {}, datesToDelete = [] } = req.body;

    console.log(`📋 [updateDateSpecificAvailability] Received scheduleId: ${scheduleId}, datesToDelete: ${datesToDelete.length}, dateSpecificHours for ${Object.keys(dateSpecificHours).length} dates`);

    if (!scheduleId || isNaN(parseInt(scheduleId))) {
      console.error('❌ [updateDateSpecificAvailability] Invalid schedule ID');
      throw new Error('Invalid schedule ID');
    }

    console.log('🔁 [updateDateSpecificAvailability] Starting database transaction...');
    await db.promise().query('START TRANSACTION');

    // Verify schedule ownership
    console.log('🔐 [updateDateSpecificAvailability] Verifying schedule ownership...');
    const [schedule] = await db.promise().query(
      `SELECT s.schedule_id 
       FROM availability_schedules s
       JOIN members m ON s.member_id = m.member_id
       WHERE m.user_id = ? AND s.schedule_id = ?`,
      [userId, scheduleId]
    );
    
    if (!schedule[0]) {
      console.error('🚫 [updateDateSpecificAvailability] Not authorized to modify this schedule');
      throw new Error('Not authorized to modify this schedule');
    }

    // Handle deletions
    if (datesToDelete.length > 0) {
      console.log(`🗑️ [updateDateSpecificAvailability] Deleting ${datesToDelete.length} dates...`);
      await db.promise().query(
        'DELETE FROM date_specific_availability WHERE schedule_id = ? AND DATE(specific_date) IN (?)',
        [scheduleId, datesToDelete]
      );
    }

    // Process updates and inserts
    console.log('🛠️ [updateDateSpecificAvailability] Processing updates and inserts...');
    for (const [dateStr, timeRanges] of Object.entries(dateSpecificHours)) {
      console.log(`📅 [updateDateSpecificAvailability] Processing date: ${dateStr} with ${timeRanges.length} time ranges`);
      
      // Delete existing entries for this date
      await db.promise().query(
        'DELETE FROM date_specific_availability WHERE schedule_id = ? AND DATE(specific_date) = ?',
        [scheduleId, dateStr]
      );

      // Insert new time ranges
      if (timeRanges.length > 0) {
        for (const range of timeRanges) {
          const startMinutes = range.start.hour * 60 + range.start.minute;
          const endMinutes = range.end.hour * 60 + range.end.minute;
          
          if (endMinutes <= startMinutes) {
            console.error(`⏰ [updateDateSpecificAvailability] Invalid time range for ${dateStr}: end time must be after start time`);
            throw new Error(`Invalid time range for ${dateStr}: end time must be after start time`);
          }

          await db.promise().query(
            'INSERT INTO date_specific_availability (schedule_id, specific_date, start_time, end_time, is_available) VALUES (?, ?, ?, ?, ?)',
            [
              scheduleId, 
              dateStr,
              `${range.start.hour.toString().padStart(2, '0')}:${range.start.minute.toString().padStart(2, '0')}:00`,
              `${range.end.hour.toString().padStart(2, '0')}:${range.end.minute.toString().padStart(2, '0')}:00`,
              true
            ]
          );
        }
      } else {
        console.log(`🚷 [updateDateSpecificAvailability] Marking date ${dateStr} as unavailable`);
        await db.promise().query(
          'INSERT INTO date_specific_availability (schedule_id, specific_date, is_available) VALUES (?, ?, ?)',
          [scheduleId, dateStr, false]
        );
      }
    }

    console.log('✅ [updateDateSpecificAvailability] Committing transaction...');
    await db.promise().query('COMMIT');
    
    // Return the updated availability
    console.log('🔄 [updateDateSpecificAvailability] Fetching updated availability...');
    const [updatedAvailability] = await db.promise().query(
      `SELECT 
        DATE_FORMAT(specific_date, '%Y-%m-%d') as dateStr,
        TIME_FORMAT(start_time, '%H:%i') as startTime,
        TIME_FORMAT(end_time, '%H:%i') as endTime
      FROM date_specific_availability
      WHERE schedule_id = ?
      ORDER BY specific_date ASC`,
      [scheduleId]
    );

    // Format response
    console.log('📊 [updateDateSpecificAvailability] Formatting response...');
    const response = {};
    updatedAvailability.forEach(entry => {
      if (!response[entry.dateStr]) {
        response[entry.dateStr] = [];
      }
      
      if (entry.startTime && entry.endTime) {
        const [startHour, startMinute] = entry.startTime.split(':').map(Number);
        const [endHour, endMinute] = entry.endTime.split(':').map(Number);
        
        response[entry.dateStr].push({
          start: { hour: startHour, minute: startMinute },
          end: { hour: endHour, minute: endMinute }
        });
      }
    });

    console.log('🎉 [updateDateSpecificAvailability] Successfully processed request');
    res.status(200).json({ 
      availability: response // Ensure this is a direct map of date strings to arrays
    });
    
  } catch (err) {
    console.error('❌ [updateDateSpecificAvailability] Error in updateDateSpecificAvailability:', err);
    await db.promise().query('ROLLBACK');
    res.status(500).json({ 
      error: 'Failed to update date-specific availability',
      details: err.message 
    });
  }
};






//edit for delete 
// // controllers/dateSpecificAvailabilityController.js
// const db = require('../config/db');

// // Get all date-specific availability for a schedule
// exports.getDateSpecificAvailability = async (req, res) => {
//   try {
//     console.log('Entering getDateSpecificAvailability controller');
//     const { scheduleId } = req.query;
//     const userId = req.user.id;
//     console.log('Received scheduleId:', scheduleId, 'userId:', userId);

//     if (!scheduleId || isNaN(parseInt(scheduleId))) {
//       console.log('Invalid schedule ID:', scheduleId);
//       return res.status(400).json({ error: 'Invalid schedule ID' });
//     }

//     // Verify schedule belongs to user
//     console.log('Verifying schedule ownership...');
//     const [schedule] = await db.promise().query(
//       `SELECT s.schedule_id 
//        FROM availability_schedules s
//        JOIN members m ON s.member_id = m.member_id
//        WHERE m.user_id = ? AND s.schedule_id = ?`,
//       [userId, scheduleId]
//     );
    
//     if (!schedule[0]) {
//       console.log('User not authorized to access schedule', scheduleId);
//       return res.status(403).json({ error: 'Not authorized to access this schedule' });
//     }

//     // Get all date-specific availability
//     console.log('Fetching date-specific availability for schedule', scheduleId);
//     const [specificDates] = await db.promise().query(
//       `SELECT 
//         specific_id as id,
//         specific_date as date,
//         TIME_FORMAT(start_time, '%H:%i') as startTime,
//         TIME_FORMAT(end_time, '%H:%i') as endTime,
//         is_available as isAvailable,
//         notes
//       FROM date_specific_availability
//       WHERE schedule_id = ?
//       ORDER BY specific_date ASC`,
//       [scheduleId]
//     );
//     console.log('Found', specificDates.length, 'date-specific availability records');

//     // Convert to frontend format
//     console.log('Converting to frontend format...');
//     const availability = {};
//     specificDates.forEach(date => {
//       const dateStr = new Date(date.date).toISOString().split('T')[0];
//       if (!availability[dateStr]) {
//         availability[dateStr] = [];
//       }
      
//       if (date.startTime && date.endTime) {
//         const [startHour, startMinute] = date.startTime.split(':').map(Number);
//         const [endHour, endMinute] = date.endTime.split(':').map(Number);
        
//         availability[dateStr].push({
//           start: { hour: startHour, minute: startMinute },
//           end: { hour: endHour, minute: endMinute }
//         });
//       }
//     });

//     console.log('Successfully processed availability data');
//     res.status(200).json({ availability });
//   } catch (err) {
//     console.error('Error getting date-specific availability:', err);
//     res.status(500).json({ error: 'Failed to get date-specific availability' });
//   }
// };

// // Update date-specific availability
// exports.updateDateSpecificAvailability = async (req, res) => {
//   try {
//     console.log('Entering updateDateSpecificAvailability controller');
//     const userId = req.user.id;
//     const { scheduleId, dateSpecificHours } = req.body;
//     console.log('Received scheduleId:', scheduleId, 'dateSpecificHours keys:', Object.keys(dateSpecificHours || {}));

//     if (!scheduleId || isNaN(parseInt(scheduleId))) {
//       console.log('Invalid schedule ID:', scheduleId);
//       return res.status(400).json({ error: 'Invalid schedule ID' });
//     }

//     if (typeof dateSpecificHours !== 'object' || dateSpecificHours === null) {
//       console.log('Invalid date-specific hours format');
//       return res.status(400).json({ error: 'Invalid date-specific hours format' });
//     }

//     // Verify schedule belongs to user
//     console.log('Verifying schedule ownership...');
//     const [schedule] = await db.promise().query(
//       `SELECT s.schedule_id 
//        FROM availability_schedules s
//        JOIN members m ON s.member_id = m.member_id
//        WHERE m.user_id = ? AND s.schedule_id = ?`,
//       [userId, scheduleId]
//     );
    
//     if (!schedule[0]) {
//       console.log('User not authorized to modify schedule', scheduleId);
//       return res.status(403).json({ error: 'Not authorized to modify this schedule' });
//     }

//     console.log('Starting database transaction...');
//     await db.promise().query('START TRANSACTION');

//     // Get existing dates to determine which ones need to be updated vs inserted
//     console.log('Fetching existing dates for schedule', scheduleId);
//     const [existingDates] = await db.promise().query(
//       'SELECT specific_date FROM date_specific_availability WHERE schedule_id = ?',
//       [scheduleId]
//     );
//     console.log('Found', existingDates.length, 'existing dates');

//     const existingDateSet = new Set(existingDates.map(d => new Date(d.specific_date).toISOString()));
//     console.log('Existing date set:', existingDateSet);

//     const updatePromises = [];
//     const insertPromises = [];

//     for (const [dateStr, timeRanges] of Object.entries(dateSpecificHours)) {
//       const date = new Date(dateStr);
//       const dateISO = date.toISOString();
//       console.log('Processing date:', dateStr, 'with', timeRanges.length, 'time ranges');
      
//       if (existingDateSet.has(dateISO)) {
//         console.log('Date exists, will update:', dateStr);
//         // First delete existing entries for this date
//         updatePromises.push(
//           db.promise().query(
//             'DELETE FROM date_specific_availability WHERE schedule_id = ? AND specific_date = ?',
//             [scheduleId, date]
//           )
//         );
//       }

//       if (timeRanges.length > 0) {
//         console.log('Adding', timeRanges.length, 'time ranges for date', dateStr);
//         for (const range of timeRanges) {
//           // Validate time range
//           if (range.end.hour < range.start.hour || 
//               (range.end.hour === range.start.hour && range.end.minute < range.start.minute)) {
//             throw new Error('Invalid time range: end time before start time');
//           }
//           if (range.start.hour === range.end.hour && range.start.minute === range.end.minute) {
//             throw new Error('Invalid time range: start and end times are the same');
//           }

//           const startTime = `${range.start.hour.toString().padStart(2, '0')}:${range.start.minute.toString().padStart(2, '0')}:00`;
//           const endTime = `${range.end.hour.toString().padStart(2, '0')}:${range.end.minute.toString().padStart(2, '0')}:00`;
//           console.log('Preparing to insert time range:', startTime, '-', endTime);
          
//           insertPromises.push(
//             db.promise().query(
//               'INSERT INTO date_specific_availability (schedule_id, specific_date, start_time, end_time, is_available) VALUES (?, ?, ?, ?, ?)',
//               [scheduleId, date, startTime, endTime, true]
//             )
//           );
//         }
//       } else {
//         console.log('Marking date', dateStr, 'as unavailable');
//         // Insert as unavailable if no time ranges
//         insertPromises.push(
//           db.promise().query(
//             'INSERT INTO date_specific_availability (schedule_id, specific_date, is_available) VALUES (?, ?, ?)',
//             [scheduleId, date, false]
//           )
//         );
//       }
//     }

//     // Execute all operations
//     console.log('Executing', updatePromises.length, 'update operations and', insertPromises.length, 'insert operations');
//     await Promise.all(updatePromises);
//     await Promise.all(insertPromises);
//     await db.promise().query('COMMIT');
//     console.log('Transaction committed successfully');

//     res.status(200).json({
//       success: true,
//       message: 'Date-specific availability updated successfully'
//     });
//   } catch (err) {
//     console.error('Error in updateDateSpecificAvailability:', err);
//     await db.promise().query('ROLLBACK');
//     console.error('Transaction rolled back due to error');
//     res.status(500).json({ 
//       error: 'Failed to update date-specific availability',
//       details: err.message 
//     });
//   }
// };










// // controllers/dateSpecificAvailabilityController.js
// const db = require('../config/db');

// // Get all date-specific availability for a schedule
// exports.getDateSpecificAvailability = async (req, res) => {
//   try {
//     const { scheduleId } = req.query;
//     const userId = req.user.id;

//     if (!scheduleId) {
//       return res.status(400).json({ error: 'Schedule ID is required' });
//     }

//     // Verify schedule belongs to user
//     const [schedule] = await db.promise().query(
//       `SELECT s.schedule_id 
//        FROM availability_schedules s
//        JOIN members m ON s.member_id = m.member_id
//        WHERE m.user_id = ? AND s.schedule_id = ?`,
//       [userId, scheduleId]
//     );
    
//     if (!schedule[0]) {
//       return res.status(403).json({ error: 'Not authorized to access this schedule' });
//     }

//     // Get all date-specific availability
//     const [specificDates] = await db.promise().query(
//       `SELECT 
//         specific_id as id,
//         specific_date as date,
//         TIME_FORMAT(start_time, '%H:%i') as startTime,
//         TIME_FORMAT(end_time, '%H:%i') as endTime,
//         is_available as isAvailable,
//         notes
//       FROM date_specific_availability
//       WHERE schedule_id = ?
//       ORDER BY specific_date ASC`,
//       [scheduleId]
//     );

//     // Convert to frontend format
//     const availability = {};
//     specificDates.forEach(date => {
//       const dateStr = new Date(date.date).toISOString().split('T')[0];
//       if (!availability[dateStr]) {
//         availability[dateStr] = [];
//       }
      
//       if (date.startTime && date.endTime) {
//         const [startHour, startMinute] = date.startTime.split(':').map(Number);
//         const [endHour, endMinute] = date.endTime.split(':').map(Number);
        
//         availability[dateStr].push({
//           start: { hour: startHour, minute: startMinute },
//           end: { hour: endHour, minute: endMinute }
//         });
//       }
//     });

//     res.status(200).json({ availability });
//   } catch (err) {
//     console.error('Error getting date-specific availability:', err);
//     res.status(500).json({ error: 'Failed to get date-specific availability' });
//   }
// };


// // Update date-specific availability - FIXED VERSION
// exports.updateDateSpecificAvailability = async (req, res) => {
//   try {
//     const userId = req.user.id;
//     const { scheduleId, dateSpecificHours } = req.body;

//     if (!scheduleId || !dateSpecificHours) {
//       return res.status(400).json({ error: 'Schedule ID and date-specific hours are required' });
//     }

//     // Verify schedule belongs to user
//     const [schedule] = await db.promise().query(
//       `SELECT s.schedule_id 
//        FROM availability_schedules s
//        JOIN members m ON s.member_id = m.member_id
//        WHERE m.user_id = ? AND s.schedule_id = ?`,
//       [userId, scheduleId]
//     );
    
//     if (!schedule[0]) {
//       return res.status(403).json({ error: 'Not authorized to modify this schedule' });
//     }

//     await db.promise().query('START TRANSACTION');

//     // Get existing dates to determine which ones need to be updated vs inserted
//     const [existingDates] = await db.promise().query(
//       'SELECT specific_date FROM date_specific_availability WHERE schedule_id = ?',
//       [scheduleId]
//     );

//     const existingDateSet = new Set(existingDates.map(d => new Date(d.specific_date).toISOString()));

//     const updatePromises = [];
//     const insertPromises = [];

//     for (const [dateStr, timeRanges] of Object.entries(dateSpecificHours)) {
//       const date = new Date(dateStr);
//       const dateISO = date.toISOString();
      
//       if (existingDateSet.has(dateISO)) {
//         // First delete existing entries for this date
//         updatePromises.push(
//           db.promise().query(
//             'DELETE FROM date_specific_availability WHERE schedule_id = ? AND specific_date = ?',
//             [scheduleId, date]
//           )
//         );
//       }

//       if (timeRanges.length > 0) {
//         for (const range of timeRanges) {
//           const startTime = `${range.start.hour.toString().padStart(2, '0')}:${range.start.minute.toString().padStart(2, '0')}:00`;
//           const endTime = `${range.end.hour.toString().padStart(2, '0')}:${range.end.minute.toString().padStart(2, '0')}:00`;
          
//           insertPromises.push(
//             db.promise().query(
//               'INSERT INTO date_specific_availability (schedule_id, specific_date, start_time, end_time, is_available) VALUES (?, ?, ?, ?, ?)',
//               [scheduleId, date, startTime, endTime, true]
//             )
//           );
//         }
//       } else {
//         // Insert as unavailable if no time ranges
//         insertPromises.push(
//           db.promise().query(
//             'INSERT INTO date_specific_availability (schedule_id, specific_date, is_available) VALUES (?, ?, ?)',
//             [scheduleId, date, false]
//           )
//         );
//       }
//     }

//     // Execute all operations
//     await Promise.all(updatePromises);
//     await Promise.all(insertPromises);
//     await db.promise().query('COMMIT');

//     res.status(200).json({
//       success: true,
//       message: 'Date-specific availability updated successfully'
//     });
//   } catch (err) {
//     await db.promise().query('ROLLBACK');
//     console.error('Error updating date-specific availability:', err);
//     res.status(500).json({ error: 'Failed to update date-specific availability' });
//   }
// };