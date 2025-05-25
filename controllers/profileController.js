// controllers/profileController.js
const db = require('../config/db');
const fs = require('fs');
const path = require('path');
const timezones = require('timezones-list'); // npm install timezones-list

exports.getProfile = async (req, res) => {
  try {
    const userId = req.user.id;
    
    const [users] = await db.promise().query(
      `SELECT 
        user_id,
        first_name,
        last_name,
        email,
        profile_image_path,
        timezone,
        language
      FROM users 
      WHERE user_id = ?`,
      [userId]
    );

    if (!users || users.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    const user = users[0];
    
    // Map database language values to display names
    const languageMap = {
      'en': 'English',
      'ar': 'Arabic',
    };

    res.status(200).json({
      firstName: user.first_name,
      lastName: user.last_name,
      email: user.email,
      profileImageUrl: user.profile_image_path,
      timezone: user.timezone || 'UTC',
      language: languageMap[user.language] || 'English'
    });
  } catch (err) {
    console.error('Profile error:', err);
    res.status(500).json({ error: 'Failed to fetch profile' });
  }
};

exports.updateProfile = async (req, res) => {
  try {
    const userId = req.user.id;
    const { firstName, lastName, language } = req.body;
    
    // Map display language names to database values
    const languageValueMap = {
      'English': 'en',
      'Arabic': 'ar',
    };
    
    const languageValue = languageValueMap[language] || 'en';

    await db.promise().query(
      `UPDATE users SET 
        first_name = ?,
        last_name = ?,
        language = ?,
        updated_at = CURRENT_TIMESTAMP
      WHERE user_id = ?`,
      [firstName, lastName, languageValue, userId]
    );

    res.status(200).json({ message: 'Profile updated successfully' });
  } catch (err) {
    console.error('Update profile error:', err);
    res.status(500).json({ error: 'Failed to update profile' });
  }
};

// controllers/profileController.js
exports.uploadProfileImage = async (req, res) => {
  try {
    const userId = req.user.id;
    
    if (!req.file) {
      return res.status(400).json({ error: 'No image uploaded' });
    }

    const fileUrl = `${req.protocol}://${req.get('host')}/uploads/profile/${req.file.filename}`;
    
    // First get old image path to delete it later
    const [users] = await db.promise().query(
      'SELECT profile_image_path FROM users WHERE user_id = ?',
      [userId]
    );
    
    const oldImagePath = users[0]?.profile_image_path;
    
    // Update database with new image path
    await db.promise().query(
      'UPDATE users SET profile_image_path = ? WHERE user_id = ?',
      [fileUrl, userId]
    );
    
    // Delete old image file if it exists and is in our uploads directory
    if (oldImagePath && oldImagePath.includes('/uploads/profile/')) {
      const filename = oldImagePath.split('/uploads/profile/')[1];
      const filePath = path.join('public', 'uploads', 'profile', filename);
      
      fs.unlink(filePath, (err) => {
        if (err) console.error('Error deleting old profile image:', err);
      });
    }

    res.status(200).json({ 
      imageUrl: fileUrl
    });
  } catch (err) {
    console.error('Upload profile image error:', err);
    res.status(500).json({ error: 'Failed to upload profile image' });
  }
};

exports.deleteProfileImage = async (req, res) => {
  try {
    const userId = req.user.id;
    
    // First get image path to delete it
    const [users] = await db.promise().query(
      'SELECT profile_image_path FROM users WHERE user_id = ?',
      [userId]
    );
    
    const imagePath = users[0]?.profile_image_path;
    
    // Remove image reference from database
    await db.promise().query(
      'UPDATE users SET profile_image_path = NULL WHERE user_id = ?',
      [userId]
    );
    
    // Delete image file if it exists and is in our uploads directory
    if (imagePath && imagePath.includes('/uploads/')) {
      const filename = imagePath.split('/uploads/')[1];
      const filePath = path.join('public', 'uploads', filename);
      
      fs.unlink(filePath, (err) => {
        if (err) console.error('Error deleting profile image:', err);
      });
    }

    res.status(200).json({ message: 'Profile image removed' });
  } catch (err) {
    console.error('Delete profile image error:', err);
    res.status(500).json({ error: 'Failed to remove profile image' });
  }
};


exports.getTimezones = async (req, res) => {
  try {
    // Get simplified timezone list
    const timezoneList = timezones.map(tz => tz.tzCode);
    
    res.status(200).json(timezoneList);
  } catch (err) {
    console.error('Get timezones error:', err);
    res.status(500).json({ error: 'Failed to get timezones' });
  }
};

exports.updateTimezone = async (req, res) => {
  try {
    const userId = req.user.id;
    const { timezone } = req.body;
    
    await db.promise().query(
      'UPDATE users SET timezone = ? WHERE user_id = ?',
      [timezone, userId]
    );

    res.status(200).json({ message: 'Timezone updated successfully' });
  } catch (err) {
    console.error('Update timezone error:', err);
    res.status(500).json({ error: 'Failed to update timezone' });
  }
};