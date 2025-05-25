// controllers/seasonalAvailabilityController.js
const db = require('../config/db');

// Helper function to check for date range overlaps
async function checkDateRangeOverlap(scheduleId, startDate, endDate, excludeSeasonId = null) {
  const [overlappingSeasons] = await db.promise().query(
    `SELECT 
      user_visible_id as seasonId,
      title as nickname, 
      start_date as startDate, 
      end_date as endDate
     FROM seasonal_availability
     WHERE schedule_id = ?
     AND (
       (start_date <= ? AND end_date >= ?) OR  -- New range starts within existing
       (start_date <= ? AND end_date >= ?) OR  -- New range ends within existing
       (start_date >= ? AND end_date <= ?)     -- New range completely within existing
     )
     ${excludeSeasonId ? 'AND user_visible_id != ?' : ''}
     ORDER BY start_date`,
    excludeSeasonId 
      ? [scheduleId, endDate, startDate, endDate, startDate, startDate, endDate, excludeSeasonId]
      : [scheduleId, endDate, startDate, endDate, startDate, startDate, endDate]
  );

  return overlappingSeasons;
}

// Check for date overlaps endpoint
exports.checkDateOverlap = async (req, res) => {
  try {
    const userId = req.user.id;
    const { scheduleId, startDate, endDate, excludeSeasonId } = req.body;

    // Validate required fields
    if (!scheduleId || !startDate || !endDate) {
      return res.status(400).json({ error: 'Missing required fields' });
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

    // Parse and validate dates
    const startDateObj = new Date(startDate);
    const endDateObj = new Date(endDate);
    
    if (isNaN(startDateObj.getTime())) {
      return res.status(400).json({ error: 'Invalid start date' });
    }
    
    if (isNaN(endDateObj.getTime())) {
      return res.status(400).json({ error: 'Invalid end date' });
    }
    
    if (startDateObj > endDateObj) {
      return res.status(400).json({ error: 'Start date must be before end date' });
    }

    // Format dates for SQL
    const startDateOnly = startDateObj.toISOString().split('T')[0];
    const endDateOnly = endDateObj.toISOString().split('T')[0];

    // Check for overlaps
    const overlappingSeasons = await checkDateRangeOverlap(
      scheduleId, 
      startDateOnly, 
      endDateOnly, 
      excludeSeasonId || null
    );

    if (overlappingSeasons.length > 0) {
      return res.status(409).json({ 
        error: 'Date range overlaps with existing seasonal hours',
        conflicts: overlappingSeasons
      });
    }

    res.status(200).json({ 
      success: true,
      message: 'No overlapping date ranges found'
    });
  } catch (err) {
    console.error('Error checking date overlap:', err);
    res.status(500).json({ 
      error: 'Failed to check date overlap',
      details: err.message 
    });
  }
};

// Create or update seasonal availability
exports.upsertSeasonalAvailability = async (req, res) => {
  try {
    const userId = req.user.id;
    const { 
      scheduleId,
      seasonId,
      nickname,
      startDate,
      endDate,
      availability
    } = req.body;

    // Validate input
    if (!scheduleId || !nickname || !startDate || !endDate || !availability) {
      return res.status(400).json({ error: 'Missing required fields' });
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
      return res.status(403).json({ error: 'Not authorized to modify this schedule' });
    }

    // Parse and validate dates
    const startDateObj = new Date(startDate);
    const endDateObj = new Date(endDate);
    const startDateOnly = startDateObj.toISOString().split('T')[0];
    const endDateOnly = endDateObj.toISOString().split('T')[0];

    // Check for overlapping date ranges
    const overlappingSeasons = await checkDateRangeOverlap(
      scheduleId, 
      startDateOnly, 
      endDateOnly, 
      seasonId || null
    );

    if (overlappingSeasons.length > 0) {
      return res.status(409).json({ 
        error: 'overlap',
        conflicts: overlappingSeasons
      });
    }


    await db.promise().query('START TRANSACTION');

    let seasonUuid;
    let seasonIdToUse;
    
    if (seasonId) {
      // Update existing season
      await db.promise().query(
        `UPDATE seasonal_availability 
         SET title = ?, start_date = ?, end_date = ?, updated_at = CURRENT_TIMESTAMP
         WHERE user_visible_id = ? AND schedule_id = ?`,
        [nickname, startDateOnly, endDateOnly, seasonId, scheduleId]
      );
      
      // Get the internal season_id
      const [existingSeason] = await db.promise().query(
        'SELECT season_id FROM seasonal_availability WHERE user_visible_id = ?',
        [seasonId]
      );
      seasonIdToUse = existingSeason[0].season_id;
      seasonUuid = seasonId;
    } else {
      // Create new season
      const [result] = await db.promise().query(
        `INSERT INTO seasonal_availability 
         (schedule_id, title, start_date, end_date) 
         VALUES (?, ?, ?, ?)`,
        [scheduleId, nickname, startDateOnly, endDateOnly]
      );
      seasonIdToUse = result.insertId;
      
      // Get the UUID for response
      const [newSeason] = await db.promise().query(
        'SELECT user_visible_id FROM seasonal_availability WHERE season_id = ?',
        [seasonIdToUse]
      );
      seasonUuid = newSeason[0].user_visible_id;
    }

    // Delete existing slots if updating
    if (seasonId) {
      await db.promise().query(
        'DELETE FROM seasonal_availability_slots WHERE season_id = ?',
        [seasonIdToUse]
      );
    }

    // Prepare day mapping
    const dayMap = {
      "Sunday": "sunday",
      "Monday": "monday",
      "Tuesday": "tuesday",
      "Wednesday": "wednesday",
      "Thursday": "thursday",
      "Friday": "friday",
      "Saturday": "saturday"
    };

    // Insert all time slots
    const insertPromises = [];
    for (const [day, timeRanges] of Object.entries(availability)) {
      const dbDay = dayMap[day];
      if (!dbDay) continue;

      for (const range of timeRanges) {
        const startTime = `${range.start.hour.toString().padStart(2, '0')}:${range.start.minute.toString().padStart(2, '0')}:00`;
        const endTime = `${range.end.hour.toString().padStart(2, '0')}:${range.end.minute.toString().padStart(2, '0')}:00`;

        insertPromises.push(
          db.promise().query(
            `INSERT INTO seasonal_availability_slots 
             (season_id, day_of_week, start_time, end_time, is_available)
             VALUES (?, ?, ?, ?, TRUE)`,
            [seasonIdToUse, dbDay, startTime, endTime]
          )
        );
      }
    }

    await Promise.all(insertPromises);
    await db.promise().query('COMMIT');

    res.status(200).json({
      success: true,
      uuid: seasonUuid,
      message: 'Seasonal availability saved successfully'
    });
  } catch (err) {
    await db.promise().query('ROLLBACK');
    console.error('Error in upsertSeasonalAvailability:', err);
    res.status(500).json({ error: 'Failed to save seasonal availability' });
  }
};



// Get all seasonal availability for a schedule
exports.getSeasonalAvailability = async (req, res) => {
  try {
    console.log('getSeasonalAvailability called with query:', req.query);
    const { scheduleId } = req.query;
    const userId = req.user.id;
    console.log('User ID:', userId, 'Schedule ID:', scheduleId);

    if (!scheduleId) {
      console.log('Schedule ID is required');
      return res.status(400).json({ error: 'Schedule ID is required' });
    }

    // Verify schedule belongs to user
    console.log('Verifying schedule ownership...');
    const [schedule] = await db.promise().query(
      `SELECT s.schedule_id 
       FROM availability_schedules s
       JOIN members m ON s.member_id = m.member_id
       WHERE m.user_id = ? AND s.schedule_id = ?`,
      [userId, scheduleId]
    );
    
    if (!schedule[0]) {
      console.log('User not authorized to access this schedule');
      return res.status(403).json({ error: 'Not authorized to access this schedule' });
    }

    // Get all seasonal availability periods
    console.log('Fetching seasonal availability periods...');
    const [seasons] = await db.promise().query(
      `SELECT 
        season_id as id,
        user_visible_id as uuid,
        title as nickname,
        start_date as startDate,
        end_date as endDate,
        is_active as isActive,
        notes,
        created_at as createdAt,
        updated_at as updatedAt
      FROM seasonal_availability
      WHERE schedule_id = ?
      ORDER BY start_date ASC`,
      [scheduleId]
    );
    console.log('Found seasons:', seasons.length);

    // Get all time slots for each season
    for (const season of seasons) {
      console.log(`Fetching slots for season ${season.id} (${season.nickname})`);
      const [slots] = await db.promise().query(
        `SELECT 
          day_of_week as dayOfWeek, 
          TIME_FORMAT(start_time, '%H:%i') as startTime,
          TIME_FORMAT(end_time, '%H:%i') as endTime,
          is_available as isAvailable
        FROM seasonal_availability_slots
        WHERE season_id = ?
        ORDER BY day_of_week, start_time`,
        [season.id]
      );
      console.log(`Found ${slots.length} slots for season ${season.id}`);

      // Convert to frontend format
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
        const dayName = dayMap[slot.dayOfWeek];
        if (!dayName) return;
        
        if (!availability[dayName]) {
          availability[dayName] = [];
        }

        const [startHour, startMinute] = slot.startTime.split(':').map(Number);
        const [endHour, endMinute] = slot.endTime.split(':').map(Number);
        
        availability[dayName].push({
          start: { hour: startHour, minute: startMinute },
          end: { hour: endHour, minute: endMinute }
        });
      });

      season.availability = availability;
      console.log(`Processed availability for season ${season.id}:`, availability);
    }

    console.log('Returning seasons data');
    res.status(200).json(seasons);
  } catch (err) {
    console.error('Error getting seasonal availability:', err);
    res.status(500).json({ error: 'Failed to get seasonal availability' });
  }
};

// Delete seasonal availability
exports.deleteSeasonalAvailability = async (req, res) => {
  try {
    console.log('deleteSeasonalAvailability called with params:', req.params);
    const userId = req.user.id;
    const { seasonId } = req.params;
    console.log('User ID:', userId, 'Season ID:', seasonId);

    if (!seasonId) {
      console.log('Season ID is required');
      return res.status(400).json({ error: 'Season ID is required' });
    }

    // Verify season belongs to user
    console.log('Verifying season ownership...');
    const [season] = await db.promise().query(
      `SELECT s.season_id 
       FROM seasonal_availability s
       JOIN availability_schedules sch ON s.schedule_id = sch.schedule_id
       JOIN members m ON sch.member_id = m.member_id
       WHERE m.user_id = ? AND s.user_visible_id = ?`,
      [userId, seasonId]
    );
    
    if (!season[0]) {
      console.log('User not authorized to delete this season');
      return res.status(403).json({ error: 'Not authorized to delete this season' });
    }

    console.log('Starting transaction...');
    await db.promise().query('START TRANSACTION');

    // Delete will cascade to slots
    console.log('Deleting seasonal availability...');
    await db.promise().query(
      'DELETE FROM seasonal_availability WHERE user_visible_id = ?',
      [seasonId]
    );

    await db.promise().query('COMMIT');
    console.log('Season deleted successfully');

    res.status(200).json({
      success: true,
      message: 'Seasonal availability deleted successfully'
    });
  } catch (err) {
    console.error('Error in deleteSeasonalAvailability:', err);
    await db.promise().query('ROLLBACK');
    console.error('Transaction rolled back due to error');
    res.status(500).json({ error: 'Failed to delete seasonal availability' });
  }
};



//edit for overlap2

// const db = require('../config/db');

// // Helper function to check for date range overlaps
// async function checkDateRangeOverlap(scheduleId, startDate, endDate, excludeSeasonId = null) {
//   const [overlappingSeasons] = await db.promise().query(
//     `SELECT title, start_date, end_date 
//      FROM seasonal_availability
//      WHERE schedule_id = ?
//      AND (
//        (start_date <= ? AND end_date >= ?) OR  -- New range starts within existing
//        (start_date <= ? AND end_date >= ?) OR  -- New range ends within existing
//        (start_date >= ? AND end_date <= ?)     -- New range completely within existing
//      )
//      ${excludeSeasonId ? 'AND user_visible_id != ?' : ''}
//      ORDER BY start_date`,
//     excludeSeasonId 
//       ? [scheduleId, endDate, startDate, endDate, startDate, startDate, endDate, excludeSeasonId]
//       : [scheduleId, endDate, startDate, endDate, startDate, startDate, endDate]
//   );

//   return overlappingSeasons.length > 0 ? overlappingSeasons : null;
// }

// // Get all seasonal availability for a schedule
// exports.getSeasonalAvailability = async (req, res) => {
//   try {
//     console.log('getSeasonalAvailability called with query:', req.query);
//     const { scheduleId } = req.query;
//     const userId = req.user.id;
//     console.log('User ID:', userId, 'Schedule ID:', scheduleId);

//     if (!scheduleId) {
//       console.log('Schedule ID is required');
//       return res.status(400).json({ error: 'Schedule ID is required' });
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
//       console.log('User not authorized to access this schedule');
//       return res.status(403).json({ error: 'Not authorized to access this schedule' });
//     }

//     // Get all seasonal availability periods
//     console.log('Fetching seasonal availability periods...');
//     const [seasons] = await db.promise().query(
//       `SELECT 
//         season_id as id,
//         user_visible_id as uuid,
//         title as nickname,
//         start_date as startDate,
//         end_date as endDate,
//         is_active as isActive,
//         notes,
//         created_at as createdAt,
//         updated_at as updatedAt
//       FROM seasonal_availability
//       WHERE schedule_id = ?
//       ORDER BY start_date ASC`,
//       [scheduleId]
//     );
//     console.log('Found seasons:', seasons.length);

//     // Get all time slots for each season
//     for (const season of seasons) {
//       console.log(`Fetching slots for season ${season.id} (${season.nickname})`);
//       const [slots] = await db.promise().query(
//         `SELECT 
//           day_of_week as dayOfWeek, 
//           TIME_FORMAT(start_time, '%H:%i') as startTime,
//           TIME_FORMAT(end_time, '%H:%i') as endTime,
//           is_available as isAvailable
//         FROM seasonal_availability_slots
//         WHERE season_id = ?
//         ORDER BY day_of_week, start_time`,
//         [season.id]
//       );
//       console.log(`Found ${slots.length} slots for season ${season.id}`);

//       // Convert to frontend format
//       const availability = {};
//       const dayMap = {
//         "sunday": "Sunday",
//         "monday": "Monday",
//         "tuesday": "Tuesday",
//         "wednesday": "Wednesday",
//         "thursday": "Thursday",
//         "friday": "Friday",
//         "saturday": "Saturday"
//       };

//       slots.forEach(slot => {
//         const dayName = dayMap[slot.dayOfWeek];
//         if (!dayName) return;
        
//         if (!availability[dayName]) {
//           availability[dayName] = [];
//         }

//         const [startHour, startMinute] = slot.startTime.split(':').map(Number);
//         const [endHour, endMinute] = slot.endTime.split(':').map(Number);
        
//         availability[dayName].push({
//           start: { hour: startHour, minute: startMinute },
//           end: { hour: endHour, minute: endMinute }
//         });
//       });

//       season.availability = availability;
//       console.log(`Processed availability for season ${season.id}:`, availability);
//     }

//     console.log('Returning seasons data');
//     res.status(200).json(seasons);
//   } catch (err) {
//     console.error('Error getting seasonal availability:', err);
//     res.status(500).json({ error: 'Failed to get seasonal availability' });
//   }
// };

// // Create or update seasonal availability
// exports.upsertSeasonalAvailability = async (req, res) => {
//   try {
//     console.log('upsertSeasonalAvailability called with body:', req.body);
//     const userId = req.user.id;
//     const { 
//       scheduleId,
//       seasonId,
//       nickname,
//       startDate,
//       endDate,
//       availability
//     } = req.body;
//     console.log('User ID:', userId, 'Schedule ID:', scheduleId, 'Season ID:', seasonId);

//     // Validate input
//     if (!scheduleId || !nickname || !startDate || !endDate || !availability) {
//       console.log('Missing required fields');
//       return res.status(400).json({ error: 'Missing required fields' });
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
//       console.log('User not authorized to modify this schedule');
//       return res.status(403).json({ error: 'Not authorized to modify this schedule' });
//     }

//     // Extract just the date portion from ISO strings
//     const startDateOnly = new Date(startDate).toISOString().split('T')[0];
//     const endDateOnly = new Date(endDate).toISOString().split('T')[0];

//     // Check for overlapping date ranges
//     const overlappingSeasons = await checkDateRangeOverlap(
//       scheduleId, 
//       startDateOnly, 
//       endDateOnly, 
//       seasonId || null
//     );

//     if (overlappingSeasons) {
//       const conflictDetails = overlappingSeasons.map(season => ({
//         nickname: season.title,
//         startDate: season.start_date,
//         endDate: season.end_date
//       }));
      
//       return res.status(409).json({ 
//         error: 'Date range overlaps with existing seasonal hours',
//         conflicts: conflictDetails
//       });
//     }

//     console.log('Starting transaction...');
//     await db.promise().query('START TRANSACTION');

//     let seasonUuid;
//     let seasonIdToUse;
    
//     if (seasonId) {
//       console.log('Updating existing season...');
//       await db.promise().query(
//         `UPDATE seasonal_availability 
//          SET title = ?, start_date = ?, end_date = ?, updated_at = CURRENT_TIMESTAMP
//          WHERE user_visible_id = ? AND schedule_id = ?`,
//         [nickname, startDateOnly, endDateOnly, seasonId, scheduleId]
//       );
      
//       // Get the internal season_id for slot insertion
//       const [existingSeason] = await db.promise().query(
//         'SELECT season_id FROM seasonal_availability WHERE user_visible_id = ?',
//         [seasonId]
//       );
//       seasonIdToUse = existingSeason[0].season_id;
//       seasonUuid = seasonId;
//     } else {
//       console.log('Creating new season...');
//       const [result] = await db.promise().query(
//         `INSERT INTO seasonal_availability 
//          (schedule_id, title, start_date, end_date) 
//          VALUES (?, ?, ?, ?)`,
//         [scheduleId, nickname, startDateOnly, endDateOnly]
//       );
//       seasonIdToUse = result.insertId;
      
//       // Get the UUID for response
//       const [newSeason] = await db.promise().query(
//         'SELECT user_visible_id FROM seasonal_availability WHERE season_id = ?',
//         [seasonIdToUse]
//       );
//       seasonUuid = newSeason[0].user_visible_id;
//     }

//     // Delete existing slots if updating
//     if (seasonId) {
//       console.log('Deleting existing slots...');
//       await db.promise().query(
//         'DELETE FROM seasonal_availability_slots WHERE season_id = ?',
//         [seasonIdToUse]
//       );
//     }

//     console.log('Preparing to insert new slots...');
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
//       if (!dbDay) continue;

//       console.log(`Processing slots for ${day} (${dbDay})`);
//       for (const range of timeRanges) {
//         const startTime = `${range.start.hour.toString().padStart(2, '0')}:${range.start.minute.toString().padStart(2, '0')}:00`;
//         const endTime = `${range.end.hour.toString().padStart(2, '0')}:${range.end.minute.toString().padStart(2, '0')}:00`;
//         console.log(`Adding slot: ${startTime} to ${endTime}`);

//         insertPromises.push(
//           db.promise().query(
//             `INSERT INTO seasonal_availability_slots 
//              (season_id, day_of_week, start_time, end_time, is_available)
//              VALUES (?, ?, ?, ?, TRUE)`,
//             [seasonIdToUse, dbDay, startTime, endTime]
//           )
//         );
//       }
//     }

//     console.log('Executing all slot insertions...');
//     await Promise.all(insertPromises);
//     await db.promise().query('COMMIT');
//     console.log('Transaction committed successfully');

//     res.status(200).json({
//       success: true,
//       uuid: seasonUuid,
//       message: 'Seasonal availability saved successfully'
//     });
//   } catch (err) {
//     console.error('Error in upsertSeasonalAvailability:', err);
//     await db.promise().query('ROLLBACK');
//     console.error('Transaction rolled back due to error');
//     res.status(500).json({ error: 'Failed to save seasonal availability' });
//   }
// };

// // Delete seasonal availability
// exports.deleteSeasonalAvailability = async (req, res) => {
//   try {
//     console.log('deleteSeasonalAvailability called with params:', req.params);
//     const userId = req.user.id;
//     const { seasonId } = req.params;
//     console.log('User ID:', userId, 'Season ID:', seasonId);

//     if (!seasonId) {
//       console.log('Season ID is required');
//       return res.status(400).json({ error: 'Season ID is required' });
//     }

//     // Verify season belongs to user
//     console.log('Verifying season ownership...');
//     const [season] = await db.promise().query(
//       `SELECT s.season_id 
//        FROM seasonal_availability s
//        JOIN availability_schedules sch ON s.schedule_id = sch.schedule_id
//        JOIN members m ON sch.member_id = m.member_id
//        WHERE m.user_id = ? AND s.user_visible_id = ?`,
//       [userId, seasonId]
//     );
    
//     if (!season[0]) {
//       console.log('User not authorized to delete this season');
//       return res.status(403).json({ error: 'Not authorized to delete this season' });
//     }

//     console.log('Starting transaction...');
//     await db.promise().query('START TRANSACTION');

//     // Delete will cascade to slots
//     console.log('Deleting seasonal availability...');
//     await db.promise().query(
//       'DELETE FROM seasonal_availability WHERE user_visible_id = ?',
//       [seasonId]
//     );

//     await db.promise().query('COMMIT');
//     console.log('Season deleted successfully');

//     res.status(200).json({
//       success: true,
//       message: 'Seasonal availability deleted successfully'
//     });
//   } catch (err) {
//     console.error('Error in deleteSeasonalAvailability:', err);
//     await db.promise().query('ROLLBACK');
//     console.error('Transaction rolled back due to error');
//     res.status(500).json({ error: 'Failed to delete seasonal availability' });
//   }
// };

// // Add this to your seasonalAvailabilityController.js
// exports.checkDateOverlap = async (req, res) => {
//   try {
//     const userId = req.user.id;
//     const { scheduleId, startDate, endDate, excludeSeasonId } = req.body;

//     if (!scheduleId || !startDate || !endDate) {
//       return res.status(400).json({ error: 'Missing required fields' });
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

//     // Extract just the date portion from ISO strings
//     const startDateOnly = new Date(startDate).toISOString().split('T')[0];
//     const endDateOnly = new Date(endDate).toISOString().split('T')[0];

//     // Check for overlapping date ranges
//     const overlappingSeasons = await checkDateRangeOverlap(
//       scheduleId, 
//       startDateOnly, 
//       endDateOnly, 
//       excludeSeasonId || null
//     );

//     if (overlappingSeasons) {
//       const conflictDetails = overlappingSeasons.map(season => ({
//         nickname: season.title,
//         startDate: season.start_date,
//         endDate: season.end_date
//       }));
      
//       return res.status(409).json({ 
//         error: 'Date range overlaps with existing seasonal hours',
//         conflicts: conflictDetails
//       });
//     }

//     res.status(200).json({ success: true });
//   } catch (err) {
//     console.error('Error checking date overlap:', err);
//     res.status(500).json({ error: 'Failed to check date overlap' });
//   }
// };


//edit for overlap 

// const db = require('../config/db');

// // Get all seasonal availability for a schedule
// exports.getSeasonalAvailability = async (req, res) => {
//   try {
//     console.log('getSeasonalAvailability called with query:', req.query);
//     const { scheduleId } = req.query;
//     const userId = req.user.id;
//     console.log('User ID:', userId, 'Schedule ID:', scheduleId);

//     if (!scheduleId) {
//       console.log('Schedule ID is required');
//       return res.status(400).json({ error: 'Schedule ID is required' });
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
//       console.log('User not authorized to access this schedule');
//       return res.status(403).json({ error: 'Not authorized to access this schedule' });
//     }

//     // Get all seasonal availability periods
//     console.log('Fetching seasonal availability periods...');
//     const [seasons] = await db.promise().query(
//       `SELECT 
//         season_id as id,
//         user_visible_id as uuid,
//         title as nickname,
//         start_date as startDate,
//         end_date as endDate,
//         is_active as isActive,
//         notes,
//         created_at as createdAt,
//         updated_at as updatedAt
//       FROM seasonal_availability
//       WHERE schedule_id = ?
//       ORDER BY start_date ASC`,
//       [scheduleId]
//     );
//     console.log('Found seasons:', seasons.length);

//     // Get all time slots for each season
//     for (const season of seasons) {
//       console.log(`Fetching slots for season ${season.id} (${season.nickname})`);
//       const [slots] = await db.promise().query(
//         `SELECT 
//           day_of_week as dayOfWeek, 
//           TIME_FORMAT(start_time, '%H:%i') as startTime,
//           TIME_FORMAT(end_time, '%H:%i') as endTime,
//           is_available as isAvailable
//         FROM seasonal_availability_slots
//         WHERE season_id = ?
//         ORDER BY day_of_week, start_time`,
//         [season.id]
//       );
//       console.log(`Found ${slots.length} slots for season ${season.id}`);

//       // Convert to frontend format
//       const availability = {};
//       const dayMap = {
//         "sunday": "Sunday",
//         "monday": "Monday",
//         "tuesday": "Tuesday",
//         "wednesday": "Wednesday",
//         "thursday": "Thursday",
//         "friday": "Friday",
//         "saturday": "Saturday"
//       };

//       slots.forEach(slot => {
//         const dayName = dayMap[slot.dayOfWeek];
//         if (!dayName) return;
        
//         if (!availability[dayName]) {
//           availability[dayName] = [];
//         }

//         const [startHour, startMinute] = slot.startTime.split(':').map(Number);
//         const [endHour, endMinute] = slot.endTime.split(':').map(Number);
        
//         availability[dayName].push({
//           start: { hour: startHour, minute: startMinute },
//           end: { hour: endHour, minute: endMinute }
//         });
//       });

//       season.availability = availability;
//       console.log(`Processed availability for season ${season.id}:`, availability);
//     }

//     console.log('Returning seasons data');
//     res.status(200).json(seasons);
//   } catch (err) {
//     console.error('Error getting seasonal availability:', err);
//     res.status(500).json({ error: 'Failed to get seasonal availability' });
//   }
// };

// // Create or update seasonal availability
// // exports.upsertSeasonalAvailability = async (req, res) => {
// //   try {
// //     console.log('upsertSeasonalAvailability called with body:', req.body);
// //     const userId = req.user.id;
// //     const { 
// //       scheduleId,
// //       seasonId,
// //       nickname,
// //       startDate,
// //       endDate,
// //       availability
// //     } = req.body;
// //     console.log('User ID:', userId, 'Schedule ID:', scheduleId, 'Season ID:', seasonId);

// //     // Validate input
// //     if (!scheduleId || !nickname || !startDate || !endDate || !availability) {
// //       console.log('Missing required fields');
// //       return res.status(400).json({ error: 'Missing required fields' });
// //     }

// //     // Verify schedule belongs to user
// //     console.log('Verifying schedule ownership...');
// //     const [schedule] = await db.promise().query(
// //       `SELECT s.schedule_id 
// //        FROM availability_schedules s
// //        JOIN members m ON s.member_id = m.member_id
// //        WHERE m.user_id = ? AND s.schedule_id = ?`,
// //       [userId, scheduleId]
// //     );
    
// //     if (!schedule[0]) {
// //       console.log('User not authorized to modify this schedule');
// //       return res.status(403).json({ error: 'Not authorized to modify this schedule' });
// //     }

// //     console.log('Starting transaction...');
// //     await db.promise().query('START TRANSACTION');

// //     let seasonUuid;
// //     // if (seasonId) {
// //     //   console.log('Updating existing season...');
// //     //   await db.promise().query(
// //     //     `UPDATE seasonal_availability 
// //     //      SET title = ?, start_date = ?, end_date = ?, updated_at = CURRENT_TIMESTAMP
// //     //      WHERE user_visible_id = ? AND schedule_id = ?`,
// //     //     [nickname, startDate, endDate, seasonId, scheduleId]
// //     //   );

// //     //   // Get the UUID for response
// //     //   const [result] = await db.promise().query(
// //     //     'SELECT user_visible_id FROM seasonal_availability WHERE user_visible_id = ?',
// //     //     [seasonId]
// //     //   );
// //     //   seasonUuid = result[0].user_visible_id;
// //     //   console.log('Updated season UUID:', seasonUuid);

// //     //   // Delete existing slots
// //     //   console.log('Deleting existing slots...');
// //     //   await db.promise().query(
// //     //     `DELETE FROM seasonal_availability_slots 
// //     //      WHERE season_id = (SELECT season_id FROM seasonal_availability WHERE user_visible_id = ?)`,
// //     //     [seasonId]
// //     //   );
// //     // } else {
// //     //   console.log('Creating new season...');
// //     //   const [result] = await db.promise().query(
// //     //     `INSERT INTO seasonal_availability 
// //     //      (schedule_id, title, start_date, end_date) 
// //     //      VALUES (?, ?, ?, ?)`,
// //     //     [scheduleId, nickname, startDate, endDate]
// //     //   );
      
// //     //   // Get the UUID for response
// //     //   const [newSeason] = await db.promise().query(
// //     //     'SELECT user_visible_id FROM seasonal_availability WHERE season_id = ?',
// //     //     [result.insertId]
// //     //   );
// //     //   seasonUuid = newSeason[0].user_visible_id;
// //     //   console.log('Created new season with UUID:', seasonUuid);
// //     // }

// // //     // Insert new slots
// // // if (seasonId) {
// // //   console.log('Updating existing season...');
// // //   await db.promise().query(
// // //     `UPDATE seasonal_availability 
// // //      SET title = ?, start_date = DATE(?), end_date = DATE(?), updated_at = CURRENT_TIMESTAMP
// // //      WHERE user_visible_id = ? AND schedule_id = ?`,
// // //     [nickname, startDate, endDate, seasonId, scheduleId]
// // //   );
// // // } else {
// // //   console.log('Creating new season...');
// // //   const [result] = await db.promise().query(
// // //     `INSERT INTO seasonal_availability 
// // //      (schedule_id, title, start_date, end_date) 
// // //      VALUES (?, ?, DATE(?), DATE(?))`,
// // //     [scheduleId, nickname, startDate, endDate]
// // //   );
// // // }


// // //     console.log('Preparing to insert new slots...');
// // //     const dayMap = {
// // //       "Sunday": "sunday",
// // //       "Monday": "monday",
// // //       "Tuesday": "tuesday",
// // //       "Wednesday": "wednesday",
// // //       "Thursday": "thursday",
// // //       "Friday": "friday",
// // //       "Saturday": "saturday"
// // //     };

// // //     const insertPromises = [];
// // //     for (const [day, timeRanges] of Object.entries(availability)) {
// // //       const dbDay = dayMap[day];
// // //       if (!dbDay) continue;

// // //       console.log(`Processing slots for ${day} (${dbDay})`);
// // //       for (const range of timeRanges) {
// // //         const startTime = `${range.start.hour.toString().padStart(2, '0')}:${range.start.minute.toString().padStart(2, '0')}:00`;
// // //         const endTime = `${range.end.hour.toString().padStart(2, '0')}:${range.end.minute.toString().padStart(2, '0')}:00`;
// // //         console.log(`Adding slot: ${startTime} to ${endTime}`);

// // //         insertPromises.push(
// // //           db.promise().query(
// // //             `INSERT INTO seasonal_availability_slots 
// // //              (season_id, day_of_week, start_time, end_time, is_available)
// // //              SELECT season_id, ?, ?, ?, TRUE 
// // //              FROM seasonal_availability 
// // //              WHERE user_visible_id = ?`,
// // //             [dbDay, startTime, endTime, seasonUuid]
// // //           )
// // //         );
// // //       }
// // //     }


// // // Insert new slots
// // let seasonIdToUse;
// // if (seasonId) {
// //   console.log('Updating existing season...');
// //   await db.promise().query(
// //     `UPDATE seasonal_availability 
// //      SET title = ?, start_date = DATE(?), end_date = DATE(?), updated_at = CURRENT_TIMESTAMP
// //      WHERE user_visible_id = ? AND schedule_id = ?`,
// //     [nickname, startDate, endDate, seasonId, scheduleId]
// //   );
  
// //   // Get the internal season_id for slot insertion
// //   const [existingSeason] = await db.promise().query(
// //     'SELECT season_id FROM seasonal_availability WHERE user_visible_id = ?',
// //     [seasonId]
// //   );
// //   seasonIdToUse = existingSeason[0].season_id;
// // } else {
// //   console.log('Creating new season...');
// //   const [result] = await db.promise().query(
// //     `INSERT INTO seasonal_availability 
// //      (schedule_id, title, start_date, end_date) 
// //      VALUES (?, ?, DATE(?), DATE(?))`,
// //     [scheduleId, nickname, startDate, endDate]
// //   );
// //   seasonIdToUse = result.insertId;
  
// //   // Get the UUID for response
// //   const [newSeason] = await db.promise().query(
// //     'SELECT user_visible_id FROM seasonal_availability WHERE season_id = ?',
// //     [seasonIdToUse]
// //   );
// //   seasonUuid = newSeason[0].user_visible_id;
// // }

// // console.log('Preparing to insert new slots...');
// // const dayMap = {
// //   "Sunday": "sunday",
// //   "Monday": "monday",
// //   "Tuesday": "tuesday",
// //   "Wednesday": "wednesday",
// //   "Thursday": "thursday",
// //   "Friday": "friday",
// //   "Saturday": "saturday"
// // };

// // const insertPromises = [];
// // for (const [day, timeRanges] of Object.entries(availability)) {
// //   const dbDay = dayMap[day];
// //   if (!dbDay) continue;

// //   console.log(`Processing slots for ${day} (${dbDay})`);
// //   for (const range of timeRanges) {
// //     const startTime = `${range.start.hour.toString().padStart(2, '0')}:${range.start.minute.toString().padStart(2, '0')}:00`;
// //     const endTime = `${range.end.hour.toString().padStart(2, '0')}:${range.end.minute.toString().padStart(2, '0')}:00`;
// //     console.log(`Adding slot: ${startTime} to ${endTime}`);

// //     insertPromises.push(
// //       db.promise().query(
// //         `INSERT INTO seasonal_availability_slots 
// //          (season_id, day_of_week, start_time, end_time, is_available)
// //          VALUES (?, ?, ?, ?, TRUE)`,
// //         [seasonIdToUse, dbDay, startTime, endTime]
// //       )
// //     );
// //   }
// // }

// //     console.log('Executing all slot insertions...');
// //     await Promise.all(insertPromises);
// //     await db.promise().query('COMMIT');
// //     console.log('Transaction committed successfully');

// //     res.status(200).json({
// //       success: true,
// //       uuid: seasonUuid,
// //       message: 'Seasonal availability saved successfully'
// //     });
// //   } catch (err) {
// //     console.error('Error in upsertSeasonalAvailability:', err);
// //     await db.promise().query('ROLLBACK');
// //     console.error('Transaction rolled back due to error');
// //     res.status(500).json({ error: 'Failed to save seasonal availability' });
// //   }
// // };
// exports.upsertSeasonalAvailability = async (req, res) => {
//   try {
//     console.log('upsertSeasonalAvailability called with body:', req.body);
//     const userId = req.user.id;
//     const { 
//       scheduleId,
//       seasonId,
//       nickname,
//       startDate,
//       endDate,
//       availability
//     } = req.body;
//     console.log('User ID:', userId, 'Schedule ID:', scheduleId, 'Season ID:', seasonId);

//     // Validate input
//     if (!scheduleId || !nickname || !startDate || !endDate || !availability) {
//       console.log('Missing required fields');
//       return res.status(400).json({ error: 'Missing required fields' });
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
//       console.log('User not authorized to modify this schedule');
//       return res.status(403).json({ error: 'Not authorized to modify this schedule' });
//     }

//     console.log('Starting transaction...');
//     await db.promise().query('START TRANSACTION');

//     let seasonUuid;
//     let seasonIdToUse;
    
//     // Extract just the date portion from ISO strings
//     const startDateOnly = new Date(startDate).toISOString().split('T')[0];
//     const endDateOnly = new Date(endDate).toISOString().split('T')[0];

//     if (seasonId) {
//       console.log('Updating existing season...');
//       await db.promise().query(
//         `UPDATE seasonal_availability 
//          SET title = ?, start_date = ?, end_date = ?, updated_at = CURRENT_TIMESTAMP
//          WHERE user_visible_id = ? AND schedule_id = ?`,
//         [nickname, startDateOnly, endDateOnly, seasonId, scheduleId]
//       );
      
//       // Get the internal season_id for slot insertion
//       const [existingSeason] = await db.promise().query(
//         'SELECT season_id FROM seasonal_availability WHERE user_visible_id = ?',
//         [seasonId]
//       );
//       seasonIdToUse = existingSeason[0].season_id;
//       seasonUuid = seasonId;
//     } else {
//       console.log('Creating new season...');
//       const [result] = await db.promise().query(
//         `INSERT INTO seasonal_availability 
//          (schedule_id, title, start_date, end_date) 
//          VALUES (?, ?, ?, ?)`,
//         [scheduleId, nickname, startDateOnly, endDateOnly]
//       );
//       seasonIdToUse = result.insertId;
      
//       // Get the UUID for response
//       const [newSeason] = await db.promise().query(
//         'SELECT user_visible_id FROM seasonal_availability WHERE season_id = ?',
//         [seasonIdToUse]
//       );
//       seasonUuid = newSeason[0].user_visible_id;
//     }

//     // Delete existing slots if updating
//     if (seasonId) {
//       console.log('Deleting existing slots...');
//       await db.promise().query(
//         'DELETE FROM seasonal_availability_slots WHERE season_id = ?',
//         [seasonIdToUse]
//       );
//     }

//     console.log('Preparing to insert new slots...');
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
//       if (!dbDay) continue;

//       console.log(`Processing slots for ${day} (${dbDay})`);
//       for (const range of timeRanges) {
//         const startTime = `${range.start.hour.toString().padStart(2, '0')}:${range.start.minute.toString().padStart(2, '0')}:00`;
//         const endTime = `${range.end.hour.toString().padStart(2, '0')}:${range.end.minute.toString().padStart(2, '0')}:00`;
//         console.log(`Adding slot: ${startTime} to ${endTime}`);

//         insertPromises.push(
//           db.promise().query(
//             `INSERT INTO seasonal_availability_slots 
//              (season_id, day_of_week, start_time, end_time, is_available)
//              VALUES (?, ?, ?, ?, TRUE)`,
//             [seasonIdToUse, dbDay, startTime, endTime]
//           )
//         );
//       }
//     }

//     console.log('Executing all slot insertions...');
//     await Promise.all(insertPromises);
//     await db.promise().query('COMMIT');
//     console.log('Transaction committed successfully');

//     res.status(200).json({
//       success: true,
//       uuid: seasonUuid,
//       message: 'Seasonal availability saved successfully'
//     });
//   } catch (err) {
//     console.error('Error in upsertSeasonalAvailability:', err);
//     await db.promise().query('ROLLBACK');
//     console.error('Transaction rolled back due to error');
//     res.status(500).json({ error: 'Failed to save seasonal availability' });
//   }
// };

// // Delete seasonal availability
// exports.deleteSeasonalAvailability = async (req, res) => {
//   try {
//     console.log('deleteSeasonalAvailability called with params:', req.params);
//     const userId = req.user.id;
//     const { seasonId } = req.params;
//     console.log('User ID:', userId, 'Season ID:', seasonId);

//     if (!seasonId) {
//       console.log('Season ID is required');
//       return res.status(400).json({ error: 'Season ID is required' });
//     }

//     // Verify season belongs to user
//     console.log('Verifying season ownership...');
//     const [season] = await db.promise().query(
//       `SELECT s.season_id 
//        FROM seasonal_availability s
//        JOIN availability_schedules sch ON s.schedule_id = sch.schedule_id
//        JOIN members m ON sch.member_id = m.member_id
//        WHERE m.user_id = ? AND s.user_visible_id = ?`,
//       [userId, seasonId]
//     );
    
//     if (!season[0]) {
//       console.log('User not authorized to delete this season');
//       return res.status(403).json({ error: 'Not authorized to delete this season' });
//     }

//     console.log('Starting transaction...');
//     await db.promise().query('START TRANSACTION');

//     // Delete will cascade to slots
//     console.log('Deleting seasonal availability...');
//     await db.promise().query(
//       'DELETE FROM seasonal_availability WHERE user_visible_id = ?',
//       [seasonId]
//     );

//     await db.promise().query('COMMIT');
//     console.log('Season deleted successfully');

//     res.status(200).json({
//       success: true,
//       message: 'Seasonal availability deleted successfully'
//     });
//   } catch (err) {
//     console.error('Error in deleteSeasonalAvailability:', err);
//     await db.promise().query('ROLLBACK');
//     console.error('Transaction rolled back due to error');
//     res.status(500).json({ error: 'Failed to delete seasonal availability' });
//   }
// };








// // controllers/seasonalAvailabilityController.js
// const db = require('../config/db');

// // Get all seasonal availability for a schedule
// exports.getSeasonalAvailability = async (req, res) => {
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

//     // Get all seasonal availability periods
//     const [seasons] = await db.promise().query(
//       `SELECT 
//         season_id as id,
//         user_visible_id as uuid,
//         title as nickname,
//         start_date as startDate,
//         end_date as endDate,
//         is_active as isActive,
//         notes,
//         created_at as createdAt,
//         updated_at as updatedAt
//       FROM seasonal_availability
//       WHERE schedule_id = ?
//       ORDER BY start_date ASC`,
//       [scheduleId]
//     );

//     // Get all time slots for each season
//     for (const season of seasons) {
//       const [slots] = await db.promise().query(
//         `SELECT 
//           day_of_week as dayOfWeek, 
//           TIME_FORMAT(start_time, '%H:%i') as startTime,
//           TIME_FORMAT(end_time, '%H:%i') as endTime,
//           is_available as isAvailable
//         FROM seasonal_availability_slots
//         WHERE season_id = ?
//         ORDER BY day_of_week, start_time`,
//         [season.id]
//       );

//       // Convert to frontend format
//       const availability = {};
//       const dayMap = {
//         "sunday": "Sunday",
//         "monday": "Monday",
//         "tuesday": "Tuesday",
//         "wednesday": "Wednesday",
//         "thursday": "Thursday",
//         "friday": "Friday",
//         "saturday": "Saturday"
//       };

//       slots.forEach(slot => {
//         const dayName = dayMap[slot.dayOfWeek];
//         if (!dayName) return;
        
//         if (!availability[dayName]) {
//           availability[dayName] = [];
//         }

//         const [startHour, startMinute] = slot.startTime.split(':').map(Number);
//         const [endHour, endMinute] = slot.endTime.split(':').map(Number);
        
//         availability[dayName].push({
//           start: { hour: startHour, minute: startMinute },
//           end: { hour: endHour, minute: endMinute }
//         });
//       });

//       season.availability = availability;
//     }

//     res.status(200).json(seasons);
//   } catch (err) {
//     console.error('Error getting seasonal availability:', err);
//     res.status(500).json({ error: 'Failed to get seasonal availability' });
//   }
// };

// // Create or update seasonal availability
// exports.upsertSeasonalAvailability = async (req, res) => {
//   try {
//     const userId = req.user.id;
//     const { 
//       scheduleId,
//       seasonId,
//       nickname,
//       startDate,
//       endDate,
//       availability
//     } = req.body;

//     // Validate input
//     if (!scheduleId || !nickname || !startDate || !endDate || !availability) {
//       return res.status(400).json({ error: 'Missing required fields' });
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

//     let seasonUuid;
//     if (seasonId) {
//       // Update existing season
//       await db.promise().query(
//         `UPDATE seasonal_availability 
//          SET title = ?, start_date = ?, end_date = ?, updated_at = CURRENT_TIMESTAMP
//          WHERE user_visible_id = ? AND schedule_id = ?`,
//         [nickname, startDate, endDate, seasonId, scheduleId]
//       );

//       // Get the UUID for response
//       const [result] = await db.promise().query(
//         'SELECT user_visible_id FROM seasonal_availability WHERE user_visible_id = ?',
//         [seasonId]
//       );
//       seasonUuid = result[0].user_visible_id;

//       // Delete existing slots
//       await db.promise().query(
//         `DELETE FROM seasonal_availability_slots 
//          WHERE season_id = (SELECT season_id FROM seasonal_availability WHERE user_visible_id = ?)`,
//         [seasonId]
//       );
//     } else {
//       // Create new season
//       const [result] = await db.promise().query(
//         `INSERT INTO seasonal_availability 
//          (schedule_id, title, start_date, end_date) 
//          VALUES (?, ?, ?, ?)`,
//         [scheduleId, nickname, startDate, endDate]
//       );
      
//       // Get the UUID for response
//       const [newSeason] = await db.promise().query(
//         'SELECT user_visible_id FROM seasonal_availability WHERE season_id = ?',
//         [result.insertId]
//       );
//       seasonUuid = newSeason[0].user_visible_id;
//     }

//     // Insert new slots
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
//       if (!dbDay) continue;

//       for (const range of timeRanges) {
//         const startTime = `${range.start.hour.toString().padStart(2, '0')}:${range.start.minute.toString().padStart(2, '0')}:00`;
//         const endTime = `${range.end.hour.toString().padStart(2, '0')}:${range.end.minute.toString().padStart(2, '0')}:00`;

//         insertPromises.push(
//           db.promise().query(
//             `INSERT INTO seasonal_availability_slots 
//              (season_id, day_of_week, start_time, end_time, is_available)
//              SELECT season_id, ?, ?, ?, TRUE 
//              FROM seasonal_availability 
//              WHERE user_visible_id = ?`,
//             [dbDay, startTime, endTime, seasonUuid]
//           )
//         );
//       }
//     }

//     await Promise.all(insertPromises);
//     await db.promise().query('COMMIT');

//     res.status(200).json({
//       success: true,
//       uuid: seasonUuid,
//       message: 'Seasonal availability saved successfully'
//     });
//   } catch (err) {
//     await db.promise().query('ROLLBACK');
//     console.error('Error saving seasonal availability:', err);
//     res.status(500).json({ error: 'Failed to save seasonal availability' });
//   }
// };

// // Delete seasonal availability
// exports.deleteSeasonalAvailability = async (req, res) => {
//   try {
//     const userId = req.user.id;
//     const { seasonId } = req.params;

//     if (!seasonId) {
//       return res.status(400).json({ error: 'Season ID is required' });
//     }

//     // Verify season belongs to user
//     const [season] = await db.promise().query(
//       `SELECT s.season_id 
//        FROM seasonal_availability s
//        JOIN availability_schedules sch ON s.schedule_id = sch.schedule_id
//        JOIN members m ON sch.member_id = m.member_id
//        WHERE m.user_id = ? AND s.user_visible_id = ?`,
//       [userId, seasonId]
//     );
    
//     if (!season[0]) {
//       return res.status(403).json({ error: 'Not authorized to delete this season' });
//     }

//     await db.promise().query('START TRANSACTION');

//     // Delete will cascade to slots
//     await db.promise().query(
//       'DELETE FROM seasonal_availability WHERE user_visible_id = ?',
//       [seasonId]
//     );

//     await db.promise().query('COMMIT');

//     res.status(200).json({
//       success: true,
//       message: 'Seasonal availability deleted successfully'
//     });
//   } catch (err) {
//     await db.promise().query('ROLLBACK');
//     console.error('Error deleting seasonal availability:', err);
//     res.status(500).json({ error: 'Failed to delete seasonal availability' });
//   }
// };