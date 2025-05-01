// controllers/bookingPageController.js

const db = require('../config/db');
const { v4: uuidv4 } = require('uuid');

exports.createBookingPage = async (req, res) => {
  try {
    const { title, color_primary, logo_url } = req.body;
    const userId = req.user.id;
    
    console.log('Received data:', { title, color_primary, logo_url, userId });

    // Generate a unique slug
    const slug = uuidv4().substring(0, 8);
    
    // Check if user already has a booking page
    const [existingPages] = await db.promise().query(
      'SELECT * FROM booking_pages WHERE user_id = ?',
      [userId]
    );
    
    if (existingPages.length > 0) {
      return res.status(400).json({ 
        error: 'User already has a booking page',
        existingPage: existingPages[0]
      });
    }
    
    // Insert new booking page with logo_url
    const [result] = await db.promise().query(
      'INSERT INTO booking_pages (user_id, slug, title, color_primary, logo_url) VALUES (?, ?, ?, ?, ?)',
      [userId, slug, title, color_primary, logo_url || null]
    );
    
    console.log('Insert result:', result);

    // Get the newly created booking page
    const [newPage] = await db.promise().query(
      'SELECT * FROM booking_pages WHERE page_id = ?',
      [result.insertId]
    );
    
    console.log('New page:', newPage[0]);

    res.status(201).json({
      message: 'Booking page created successfully',
      page: newPage[0]
    });
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
    
    const [pages] = await db.promise().query(
      'SELECT * FROM booking_pages WHERE user_id = ?',
      [userId]
    );
    
    res.status(200).json(pages);
  } catch (err) {
    console.error('Error fetching booking pages:', err);
    res.status(500).json({ 
      error: 'Failed to fetch booking pages',
      details: err.message 
    });
  }
};

exports.updateBookingPage = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;
    const { title, color_primary, logo_url } = req.body;
    
    // Check if page belongs to user
    const [existingPage] = await db.promise().query(
      'SELECT * FROM booking_pages WHERE page_id = ? AND user_id = ?',
      [id, userId]
    );
    
    if (existingPage.length === 0) {
      return res.status(404).json({ error: 'Booking page not found' });
    }
    
    // Update page
    await db.promise().query(
      'UPDATE booking_pages SET title = ?, color_primary = ?, logo_url = ? WHERE page_id = ?',
      [title, color_primary, logo_url, id]
    );
    
    // Get the updated booking page
    const [updatedPage] = await db.promise().query(
      'SELECT * FROM booking_pages WHERE page_id = ?',
      [id]
    );
    
    res.status(200).json({ 
      message: 'Booking page updated successfully',
      page: updatedPage[0]
    });
  } catch (err) {
    console.error('Error updating booking page:', err);
    res.status(500).json({ 
      error: 'Failed to update booking page',
      details: err.message 
    });
  }
};
// const db = require('../config/db');
// const { v4: uuidv4 } = require('uuid');

// exports.createBookingPage = async (req, res) => {
//   try {
//     const { title, color_primary } = req.body;
//     const userId = req.user.id;
    
//     // Generate a unique slug
//     const slug = uuidv4().substring(0, 8);
    
//     // Check if user already has a booking page
//     const [existingPages] = await db.promise().query(
//       'SELECT * FROM booking_pages WHERE user_id = ?',
//       [userId]
//     );
    
//     if (existingPages.length > 0) {
//       return res.status(400).json({ 
//         error: 'User already has a booking page',
//         existingPage: existingPages[0]
//       });
//     }
    
//     // Insert new booking page
//     const [result] = await db.promise().query(
//       'INSERT INTO booking_pages (user_id, slug, title, color_primary) VALUES (?, ?, ?, ?)',
//       [userId, slug, title, color_primary]
//     );
    
//     res.status(201).json({
//       message: 'Booking page created successfully',
//       page: {
//         id: result.insertId,
//         slug,
//         title,
//         color_primary
//       }
//     });
//   } catch (err) {
//     console.error('Error creating booking page:', err);
//     res.status(500).json({ error: 'Failed to create booking page' });
//   }
// };

// exports.getUserBookingPages = async (req, res) => {
//   try {
//     const userId = req.user.id;
    
//     const [pages] = await db.promise().query(
//       'SELECT * FROM booking_pages WHERE user_id = ?',
//       [userId]
//     );
    
//     res.status(200).json(pages);
//   } catch (err) {
//     console.error('Error fetching booking pages:', err);
//     res.status(500).json({ error: 'Failed to fetch booking pages' });
//   }
// };

// exports.updateBookingPage = async (req, res) => {
//   try {
//     const { id } = req.params;
//     const userId = req.user.id;
//     const { title, color_primary, logo_url } = req.body;
    
//     // Check if page belongs to user
//     const [existingPage] = await db.promise().query(
//       'SELECT * FROM booking_pages WHERE page_id = ? AND user_id = ?',
//       [id, userId]
//     );
    
//     if (existingPage.length === 0) {
//       return res.status(404).json({ error: 'Booking page not found' });
//     }
    
//     // Update page
//     await db.promise().query(
//       'UPDATE booking_pages SET title = ?, color_primary = ?, logo_url = ? WHERE page_id = ?',
//       [title, color_primary, logo_url, id]
//     );
    
//     res.status(200).json({ message: 'Booking page updated successfully' });
//   } catch (err) {
//     console.error('Error updating booking page:', err);
//     res.status(500).json({ error: 'Failed to update booking page' });
//   }
// };