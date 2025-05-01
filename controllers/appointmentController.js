// // controllers\appointmentController.js
const db = require('../config/db');

// Create or update appointment types
exports.handlePreferences = async (req, res) => {
  try {
    if (!req.user?.id) {
      return res.status(401).json({ error: 'Unauthorized' });
    }

    // Check if user already has an organization
    const [existingOrg] = await db.promise().query(
      'SELECT organization_id FROM members WHERE user_id = ?',
      [req.user.id]
    );

    let organizationId;
    
    if (existingOrg.length > 0) {
      // Use existing organization
      organizationId = existingOrg[0].organization_id;
    } else {
      // Create new organization
      const [orgResult] = await db.promise().query(
        'INSERT INTO organizations (name) VALUES (?)',
        [`${req.user.name}'s Organization`]
      );
      organizationId = orgResult.insertId;
      
      // Add user as owner
      await db.promise().query(
        'INSERT INTO members (user_id, organization_id, role) VALUES (?, ?, ?)',
        [req.user.id, organizationId, 'owner']
      );
    }

    const types = req.body.types;
    const results = [];

    for (const type of types) {
      if (type.type_id) {
        // Update existing type
        const [result] = await db.promise().query(
          `UPDATE appointment_types SET
            name = ?,
            description = ?,
            duration_minutes = ?,
            buffer_before_minutes = ?,
            buffer_after_minutes = ?,
            meeting_type = ?,
            location = ?,
            video_provider = ?,
            color_hex = ?,
            is_active = ?,
            zoom_meeting_template = ?,
            auto_generate_meeting = ?
          WHERE type_id = ? AND organization_id = ?`,
          [
            type.name,
            type.description || null,
            type.duration,
            type.buffer_before_minutes || 0,
            type.buffer_after_minutes || 0,
            type.meeting_type,
            type.meeting_type === 'in_person' ? 'Your Office' : null,
            type.meeting_type === 'video_call' ? 'zoom' : null,
            type.color_hex,
            type.is_active,
            type.zoom_meeting_template || null,
            type.auto_generate_meeting !== false,
            type.type_id,
            organizationId
          ]
        );
        results.push({ type_id: type.type_id, action: 'updated' });
      } else {
        // Create new type
        const [result] = await db.promise().query(
          `INSERT INTO appointment_types (
            organization_id, name, description, duration_minutes,
            buffer_before_minutes, buffer_after_minutes, meeting_type,
            location, video_provider, color_hex, is_active,
            zoom_meeting_template, auto_generate_meeting
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
          [
            organizationId,
            type.name,
            type.description || null,
            type.duration,
            type.buffer_before_minutes || 0,
            type.buffer_after_minutes || 0,
            type.meeting_type,
            type.meeting_type === 'in_person' ? 'Your Office' : null,
            type.meeting_type === 'video_call' ? 'zoom' : null,
            type.color_hex,
            type.is_active,
            type.zoom_meeting_template || null,
            type.auto_generate_meeting !== false
          ]
        );
        const newTypeId = result.insertId;
        
        // Assign to staff member
        await db.promise().query(
          'INSERT IGNORE INTO staff_services (staff_id, type_id) VALUES (?, ?)',
          [req.user.id, newTypeId]
        );
        
        results.push({ type_id: newTypeId, action: 'created' });
      }
    }

    res.status(200).json({
      success: true,
      message: 'Preferences processed successfully',
      organizationId,
      results
    });

  } catch (err) {
    console.error('Error handling preferences:', err);
    res.status(500).json({ 
      error: 'Failed to process preferences',
      details: err.message 
    });
  }
};

// Get user's appointment types
exports.getUserTypes = async (req, res) => {
  try {
    if (!req.user?.id) {
      return res.status(401).json({ error: 'Unauthorized' });
    }

    const [types] = await db.promise().query(`
      SELECT at.* FROM appointment_types at
      JOIN staff_services ss ON at.type_id = ss.type_id
      WHERE ss.staff_id = ?
    `, [req.user.id]);

    res.json(types);
  } catch (err) {
    console.error('Error getting appointment types:', err);
    res.status(500).json({ error: 'Failed to get appointment types' });
  }
};
// const db = require('../config/db');

// // Create new appointment types (for step1)
// exports.createAppointmentTypes = async (req, res) => {
//   try {
//     if (!req.user?.id) {
//       return res.status(401).json({ error: 'Unauthorized' });
//     }

//     // Check if user already has an organization
//     const [existingOrg] = await db.promise().query(
//       'SELECT organization_id FROM members WHERE user_id = ?',
//       [req.user.id]
//     );

//     let organizationId;
    
//     if (existingOrg.length > 0) {
//       // Use existing organization
//       organizationId = existingOrg[0].organization_id;
//     } else {
//       // Create new organization
//       const [orgResult] = await db.promise().query(
//         'INSERT INTO organizations (name) VALUES (?)',
//         [`${req.user.name}'s Organization`]
//       );
//       organizationId = orgResult.insertId;
      
//       // Add user as owner
//       await db.promise().query(
//         'INSERT INTO members (user_id, organization_id, role) VALUES (?, ?, ?)',
//         [req.user.id, organizationId, 'owner']
//       );
//     }

//     // Create appointment types
//     const types = req.body.types;
//     const typeValues = types.map(type => [
//       organizationId,
//       type.name,
//       null, // description
//       type.duration,
//       0, // buffer_before_minutes
//       0, // buffer_after_minutes
//       type.meeting_type,
//       type.meeting_type === 'in_person' ? 'Your Office' : null, // location
//       type.meeting_type === 'video_call' ? 'zoom' : null, // video_provider
//       type.color_hex,
//       type.is_active,
//       null, // zoom_meeting_template
//       true // auto_generate_meeting
//     ]);

//     await db.promise().query(
//       `INSERT INTO appointment_types (
//         organization_id, name, description, duration_minutes, 
//         buffer_before_minutes, buffer_after_minutes, meeting_type, 
//         location, video_provider, color_hex, is_active, 
//         zoom_meeting_template, auto_generate_meeting
//       ) VALUES ?`,
//       [typeValues]
//     );

//     // Assign these types to the staff member
//     const [insertedTypes] = await db.promise().query(
//       'SELECT type_id FROM appointment_types WHERE organization_id = ?',
//       [organizationId]
//     );

//     const staffAssignmentValues = insertedTypes.map(type => [req.user.id, type.type_id]);
    
//     await db.promise().query(
//       'INSERT INTO staff_services (staff_id, type_id) VALUES ?',
//       [staffAssignmentValues]
//     );

//     res.status(201).json({
//       success: true,
//       message: 'Appointment types created successfully',
//       organizationId,
//       types: insertedTypes
//     });

//   } catch (err) {
//     console.error('Error creating appointment types:', err);
//     res.status(500).json({ 
//       error: 'Failed to create appointment types',
//       details: err.message 
//     });
//   }
// };

// // Get user's appointment types
// exports.getUserTypes = async (req, res) => {
//   try {
//     if (!req.user?.id) {
//       return res.status(401).json({ error: 'Unauthorized' });
//     }

//     const [types] = await db.promise().query(`
//       SELECT at.* FROM appointment_types at
//       JOIN staff_services ss ON at.type_id = ss.type_id
//       WHERE ss.staff_id = ?
//     `, [req.user.id]);

//     res.json(types);
//   } catch (err) {
//     console.error('Error getting appointment types:', err);
//     res.status(500).json({ error: 'Failed to get appointment types' });
//   }
// };

// // Update appointment type preferences
// exports.updatePreferences = async (req, res) => {
//   try {
//     if (!req.user?.id) {
//       return res.status(401).json({ error: 'Unauthorized' });
//     }

//     const { types } = req.body;
    
//     // Update each type
//     for (const type of types) {
//       await db.promise().query(
//         `UPDATE appointment_types 
//         SET is_active = ?, duration_minutes = ?
//         WHERE type_id = ? AND organization_id IN (
//           SELECT organization_id FROM members WHERE user_id = ?
//         )`,
//         [type.is_active, type.duration, type.type_id, req.user.id]
//       );
//     }

//     res.json({ success: true, message: 'Preferences updated successfully' });
//   } catch (err) {
//     console.error('Error updating preferences:', err);
//     res.status(500).json({ error: 'Failed to update preferences' });
//   }
// };
