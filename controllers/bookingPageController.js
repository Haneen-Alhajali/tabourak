// controllers/bookingPageController.js
const db = require('../config/db');
const { v4: uuidv4 } = require('uuid');

exports.createBookingPage = async (req, res) => {
  try {
    const { title, color_primary, logo_url } = req.body;
    const userId = req.user.id;
    
    console.log('Creating booking page with:', { title, color_primary, logo_url });

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

    // Generate a base slug that will be used for all appointments
    const baseSlug = uuidv4().substring(0, 8);
    
    // Get all appointments for this member (regardless of is_active status)
    const [appointments] = await db.promise().query(
      'SELECT appointment_id FROM appointments WHERE member_id = ?',
      [memberId]
    );

    if (appointments.length === 0) {
      return res.status(400).json({ 
        error: 'No appointments found. Please complete step 1 first.' 
      });
    }

    await db.promise().query('START TRANSACTION');

    try {
      // Update ALL appointments with the same booking page settings
      const updatePromises = appointments.map(appt => {
        return db.promise().query(
          `UPDATE appointments SET 
            page_title = ?,
            page_color_primary = ?,
            page_logo_url = ?,
            slug = ?,
            updated_at = CURRENT_TIMESTAMP
           WHERE appointment_id = ?`,
          [
            title,
            color_primary,
            logo_url || null,
            `${baseSlug}-${appt.appointment_id}`, // Unique slug per appointment
            appt.appointment_id
          ]
        );
      });

      await Promise.all(updatePromises);

      await db.promise().query('COMMIT');
      
      // Return success with the first updated appointment details
      const [updatedAppointment] = await db.promise().query(
        'SELECT * FROM appointments WHERE appointment_id = ?',
        [appointments[0].appointment_id]
      );

      res.status(201).json({
        message: 'Booking page settings applied to all appointment types',
        appointment: updatedAppointment[0]
      });
    } catch (err) {
      await db.promise().query('ROLLBACK');
      throw err;
    }
  } catch (err) {
    console.error('Error creating booking page:', err);
    res.status(500).json({ 
      error: 'Failed to create booking page',
      details: err.message 
    });
  }
};

exports.getUserBookingPages = async (req, res) => {
  try {
    const userId = req.user.id;
    
    // Get member info
    const [member] = await db.promise().query(
      'SELECT member_id FROM members WHERE user_id = ?',
      [userId]
    );

    if (!member[0]) {
      return res.status(404).json({ error: 'Member not found' });
    }

    const memberId = member[0].member_id;
    
    // Get any appointment with booking page settings (no is_active filter)
    const [appointments] = await db.promise().query(
      `SELECT 
        appointment_id,
        page_title as title,
        page_color_primary as color_primary,
        page_logo_url as logo_url,
        slug,
        updated_at
       FROM appointments 
       WHERE member_id = ?
       ORDER BY appointment_id ASC
       LIMIT 1`,
      [memberId]
    );
    
    if (appointments.length === 0) {
      return res.status(404).json({ error: 'No appointments found' });
    }

    res.status(200).json(appointments[0]);
  } catch (err) {
    console.error('Error fetching booking page:', err);
    res.status(500).json({ 
      error: 'Failed to fetch booking page settings',
      details: err.message 
    });
  }
};

exports.updateBookingPage = async (req, res) => {
  try {
    const userId = req.user.id;
    const { title, color_primary, logo_url } = req.body;
    
    // Get member info
    const [member] = await db.promise().query(
      'SELECT member_id FROM members WHERE user_id = ?',
      [userId]
    );

    if (!member[0]) {
      return res.status(404).json({ error: 'Member not found' });
    }

    const memberId = member[0].member_id;

    // Get ALL appointments for this member (not filtered by is_active)
    const [appointments] = await db.promise().query(
      'SELECT appointment_id FROM appointments WHERE member_id = ?',
      [memberId]
    );

    if (appointments.length === 0) {
      return res.status(400).json({ 
        error: 'No appointments found' 
      });
    }

    await db.promise().query('START TRANSACTION');

    try {
      // Update ALL appointments with the new booking page settings
      const updatePromises = appointments.map(appt => {
        return db.promise().query(
          `UPDATE appointments SET 
            page_title = ?,
            page_color_primary = ?,
            page_logo_url = ?,
            updated_at = CURRENT_TIMESTAMP
           WHERE appointment_id = ?`,
          [
            title,
            color_primary,
            logo_url || null,
            appt.appointment_id
          ]
        );
      });

      await Promise.all(updatePromises);

      await db.promise().query('COMMIT');
      
      // Return the first updated appointment
      const [updatedAppointment] = await db.promise().query(
        'SELECT * FROM appointments WHERE appointment_id = ?',
        [appointments[0].appointment_id]
      );

      res.status(200).json({
        message: 'Booking page settings updated for all appointment types',
        appointment: updatedAppointment[0]
      });
    } catch (err) {
      await db.promise().query('ROLLBACK');
      throw err;
    }
  } catch (err) {
    console.error('Error updating booking page:', err);
    res.status(500).json({ 
      error: 'Failed to update booking page',
      details: err.message 
    });
  }
};

