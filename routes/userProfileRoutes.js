// routes\userProfileRoutes.js
const express = require('express');
const router = express.Router();
const db = require('../config/db');
const authMiddleware = require('../middleware/authMiddleware');

// Get user profile information
router.get('/user-profile', authMiddleware, async (req, res) => {
  try {
    const [users] = await db.promise().query(
      `SELECT 
        user_id as id,
        first_name,
        last_name,
        email,
        profile_image_path
      FROM users 
      WHERE user_id = ?`,
      [req.user.id]
    );

    if (!users || users.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    const user = users[0];
    const response = {
      id: user.id,
      name: `${user.first_name} ${user.last_name}`,
      email: user.email,
      profileImage: user.profile_image_path,
      initials: `${user.first_name.charAt(0)}${user.last_name.charAt(0)}`.toUpperCase(),
      // Color can be generated based on user initials or ID for consistency
      color: generateColorFromName(`${user.first_name} ${user.last_name}`)
    };

    res.status(200).json(response);
  } catch (err) {
    console.error('Profile error:', err);
    res.status(500).json({ error: 'Server error' });
  }
});

// Helper function to generate a consistent color from a name
function generateColorFromName(name) {
  // Simple hash function to convert name to a color
  let hash = 0;
  for (let i = 0; i < name.length; i++) {
    hash = name.charCodeAt(i) + ((hash << 5) - hash);
  }
  
  const hue = Math.abs(hash % 360);
  return `hsl(${hue}, 70%, 60%)`; // Return HSL color with fixed saturation and lightness
}

module.exports = router;