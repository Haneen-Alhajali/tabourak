// controllers/meetingTypeController.js
const db = require('../config/db');
const { v4: uuidv4 } = require('uuid');

// Get all meeting types for a user
exports.getMeetingTypes = async (req, res) => {
  try {
    const userId = req.user.id;
    
    // Get member ID
    const [member] = await db.promise().query(
      'SELECT member_id, organization_id FROM members WHERE user_id = ?',
      [userId]
    );
    
    if (!member[0]) {
      return res.status(404).json({ error: 'Member not found' });
    }
    
    const memberId = member[0].member_id;
    const organizationId = member[0].organization_id;

    // Get the user's individual scheduling page
    const [pages] = await db.promise().query(
      `SELECT page_id FROM scheduling_pages 
       WHERE organization_id = ? AND owner_member_id = ? AND page_type = 'individual'`,
      [organizationId, memberId]
    );

    if (pages.length === 0) {
      return res.status(200).json([]);
    }

    const pageId = pages[0].page_id;

    // Get all appointments with their details
    const [appointments] = await db.promise().query(
      `SELECT 
        a.appointment_id,
        a.name as title,
        CONCAT(a.duration_minutes, ' minutes') as duration,
        CASE 
          WHEN a.attendee_type = 'group' THEN 'Group Meeting'
          ELSE 'One-on-One'
        END as type,
        CONCAT('https://appt.link/', a.slug) as link,
        a.page_color_primary as color,
        a.attendee_type = 'group' as isGroup
      FROM appointments a
      WHERE a.page_id = ?
      ORDER BY a.created_at DESC`,
      [pageId]
    );

    res.status(200).json(appointments);
  } catch (err) {
    console.error('Error getting meeting types:', err);
    res.status(500).json({ error: 'Failed to get meeting types' });
  }
};

// Create a new meeting type
exports.createMeetingType = async (req, res) => {
  try {
    const userId = req.user.id;
    const { title, isGroup } = req.body;
    
    if (!title) {
      return res.status(400).json({ error: 'Meeting type name is required' });
    }

    // Get member and organization info
    const [member] = await db.promise().query(
      `SELECT m.member_id, m.organization_id 
       FROM members m
       WHERE m.user_id = ?`,
      [userId]
    );
    
    if (!member[0]) {
      return res.status(404).json({ error: 'Member not found' });
    }
    
    const memberId = member[0].member_id;
    const organizationId = member[0].organization_id;

    // Get the user's individual scheduling page (create if doesn't exist)
    const [pages] = await db.promise().query(
      `SELECT page_id FROM scheduling_pages 
       WHERE organization_id = ? AND owner_member_id = ? AND page_type = 'individual'`,
      [organizationId, memberId]
    );

    let pageId;
    if (pages.length === 0) {
      // Create new individual scheduling page
      const slug = uuidv4().substring(0, 8);
      const [pageResult] = await db.promise().query(
        `INSERT INTO scheduling_pages (
          organization_id, page_slug, page_title, 
          page_type, owner_member_id
        ) VALUES (?, ?, ?, ?, ?, ?)`,
        [
          organizationId,
          slug,
          `Meet with ${req.user.name}`,
          'individual',
          memberId
        ]
      );
      pageId = pageResult.insertId;
    } else {
      pageId = pages[0].page_id;
    }

    // Get default availability schedule for this member
    const [schedules] = await db.promise().query(
      'SELECT schedule_id FROM availability_schedules WHERE member_id = ? AND is_default = TRUE LIMIT 1',
      [memberId]
    );
    
    if (schedules.length === 0) {
      return res.status(400).json({ error: 'No availability schedule found. Please set up availability first.' });
    }
    
    const scheduleId = schedules[0].schedule_id;
    const slug = title.toLowerCase().replace(/\s+/g, '-') + '-' + uuidv4().substring(0, 6);

    await db.promise().query('START TRANSACTION');

    // Insert new appointment
    const [result] = await db.promise().query(
      `INSERT INTO appointments (
        organization_id, page_id, schedule_id, name, 
        duration_minutes, meeting_type, attendee_type,
        slug, page_color_primary
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        organizationId,
        pageId,
        scheduleId,
        title,
        30, // Default duration
        'video_call', // Default meeting type
        isGroup ? 'group' : 'one_on_one',
        slug,
        '#1C8B97' // Default blue color
      ]
    );

    // Link the appointment to the member
    await db.promise().query(
      `INSERT INTO appointment_type_members (
        appointment_id, member_id, is_primary
      ) VALUES (?, ?, ?)`,
      [result.insertId, memberId, true]
    );

    await db.promise().query('COMMIT');

    res.status(201).json({
      success: true,
      appointmentId: result.insertId,
      slug: slug
    });
  } catch (err) {
    await db.promise().query('ROLLBACK');
    console.error('Error creating meeting type:', err);
    res.status(500).json({ 
      error: 'Failed to create meeting type',
      details: err.message 
    });
  }
};

// Delete a meeting type
exports.deleteMeetingType = async (req, res) => {
  try {
    const userId = req.user.id;
    const { appointmentId } = req.params;

    // Verify the appointment belongs to the user
    const [appointments] = await db.promise().query(
      `SELECT a.appointment_id 
       FROM appointments a
       JOIN scheduling_pages sp ON a.page_id = sp.page_id
       JOIN members m ON sp.owner_member_id = m.member_id
       WHERE a.appointment_id = ? AND m.user_id = ?`,
      [appointmentId, userId]
    );
    
    if (appointments.length === 0) {
      return res.status(404).json({ error: 'Meeting type not found or not authorized' });
    }

    await db.promise().query('START TRANSACTION');

    // Delete from appointment_type_members first
    await db.promise().query(
      'DELETE FROM appointment_type_members WHERE appointment_id = ?',
      [appointmentId]
    );

    // Then delete the appointment
    await db.promise().query(
      'DELETE FROM appointments WHERE appointment_id = ?',
      [appointmentId]
    );

    await db.promise().query('COMMIT');

    res.status(200).json({ success: true });
  } catch (err) {
    await db.promise().query('ROLLBACK');
    console.error('Error deleting meeting type:', err);
    res.status(500).json({ error: 'Failed to delete meeting type' });
  }
};

// // controllers/meetingTypeController.js
// const db = require('../config/db');
// const { v4: uuidv4 } = require('uuid');

// // Get all meeting types for a user
// exports.getMeetingTypes = async (req, res) => {
//   try {
//     const userId = req.user.id;
    
//     // Get member ID
//     const [member] = await db.promise().query(
//       'SELECT member_id FROM members WHERE user_id = ?',
//       [userId]
//     );
    
//     if (!member[0]) {
//       return res.status(404).json({ error: 'Member not found' });
//     }
    
//     const memberId = member[0].member_id;

//     // Get all appointments with their details
//     const [appointments] = await db.promise().query(
//       `SELECT 
//         a.appointment_id,
//         a.name as title,
//         CONCAT(a.duration_minutes, ' minutes') as duration,
//         CASE 
//           WHEN a.attendee_type = 'group' THEN 'Group Meeting'
//           ELSE 'One-on-One'
//         END as type,
//         CONCAT('https://appt.link/', a.slug) as link,
//         a.page_color_primary as color,
//         a.attendee_type = 'group' as isGroup
//       FROM appointments a
//       WHERE a.member_id = ?
//       ORDER BY a.created_at DESC`,
//       [memberId, memberId]
//     );
//     res.status(200).json(appointments);
//   } catch (err) {
//     console.error('Error getting meeting types:', err);
//     res.status(500).json({ error: 'Failed to get meeting types' });
//   }
// };

// // Create a new meeting type
// exports.createMeetingType = async (req, res) => {
//   try {
//     const userId = req.user.id;
//     const { title, isGroup } = req.body;
    
//     if (!title) {
//       return res.status(400).json({ error: 'Meeting type name is required' });
//     }

//     // Get member and organization info
//     const [member] = await db.promise().query(
//       `SELECT m.member_id, m.organization_id 
//        FROM members m
//        WHERE m.user_id = ?`,
//       [userId]
//     );
    
//     if (!member[0]) {
//       return res.status(404).json({ error: 'Member not found' });
//     }
    
//     const memberId = member[0].member_id;
//     const organizationId = member[0].organization_id;

//     // Get default availability schedule for this member
//     const [schedules] = await db.promise().query(
//       'SELECT schedule_id FROM availability_schedules WHERE member_id = ? AND is_default = TRUE LIMIT 1',
//       [memberId]
//     );
    
//     if (schedules.length === 0) {
//       return res.status(400).json({ error: 'No availability schedule found. Please set up availability first.' });
//     }
    
//     const scheduleId = schedules[0].schedule_id;
//     const slug = title.toLowerCase().replace(/\s+/g, '-') + '-' + uuidv4().substring(0, 6);

//     await db.promise().query('START TRANSACTION');

//     // Insert new appointment
//     const [result] = await db.promise().query(
//       `INSERT INTO appointments (
//         organization_id, member_id, schedule_id, name, 
//         duration_minutes, meeting_type, attendee_type,
//         slug, page_title, page_color_primary
//       ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
//       [
//         organizationId,
//         memberId,
//         scheduleId,
//         title,
//         30, // Default duration
//         'video_call', // Default meeting type
//         isGroup ? 'group' : 'one_on_one',
//         slug,
//         `Meet with ${req.user.name}`,
//         '#1C8B97' // Default blue color
//       ]
//     );

//     await db.promise().query('COMMIT');

//     res.status(201).json({
//       success: true,
//       appointmentId: result.insertId,
//       slug: slug
//     });
//   } catch (err) {
//     await db.promise().query('ROLLBACK');
//     console.error('Error creating meeting type:', err);
//     res.status(500).json({ 
//       error: 'Failed to create meeting type',
//       details: err.message 
//     });
//   }
// };

// // Delete a meeting type
// exports.deleteMeetingType = async (req, res) => {
//     try {
//       const userId = req.user.id;
//       const { appointmentId } = req.params;
  
//       // Verify the appointment belongs to the user
//       const [appointments] = await db.promise().query(
//         `SELECT a.appointment_id 
//          FROM appointments a
//          JOIN members m ON a.member_id = m.member_id
//          WHERE a.appointment_id = ? AND m.user_id = ?`,
//         [appointmentId, userId]
//       );
      
//       if (appointments.length === 0) {
//         return res.status(404).json({ error: 'Meeting type not found or not authorized' });
//       }
  
//       // Hard delete the meeting type
//       await db.promise().query(
//         'DELETE FROM appointments WHERE appointment_id = ?',
//         [appointmentId]
//       );
  
//       res.status(200).json({ success: true });
//     } catch (err) {
//       console.error('Error deleting meeting type:', err);
//       res.status(500).json({ error: 'Failed to delete meeting type' });
//     }
//   };