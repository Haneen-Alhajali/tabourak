// controllers/settingsController.js
const db = require('../config/db');

exports.getSettings = async (req, res) => {
  try {
    const userId = req.user.id;
    
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

    // Get the user's individual scheduling page
    const [pages] = await db.promise().query(
      `SELECT 
        page_id,
        page_title as title,
        page_slug as slug,
        page_welcome_message as welcome_message,
        page_logo_url as logo_url
       FROM scheduling_pages 
       WHERE organization_id = ? AND owner_member_id = ? AND page_type = 'individual'
       LIMIT 1`,
      [organizationId, memberId]
    );
    
    if (pages.length === 0) {
      return res.status(404).json({ error: 'No scheduling page found' });
    }

    const page = pages[0];
    
    // Construct the settings object to match frontend expectations
    const settings = {
      'Page Title': page.title || 'Meet with User',
      'Page URL': `${process.env.FRONTEND_BASE_URL || 'https://appt.link'}/meet-with-${page.slug}`,
      'Welcome Message': page.welcome_message || 'No welcome message provided.',
      'Language': 'English', // Default for now, can be pulled from user profile later
      'Logo URL': page.logo_url || null
    };

    res.status(200).json(settings);
  } catch (err) {
    console.error('Error fetching settings:', err);
    res.status(500).json({ 
      error: 'Failed to fetch settings',
      details: err.message 
    });
  }
};