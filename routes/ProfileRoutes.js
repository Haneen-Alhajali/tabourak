// routes/profileRoutes.js
const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const profileController = require('../controllers/profileController');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Configure storage for profile images
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const uploadDir = 'public/uploads/profile';
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, 'profile-' + req.user.id + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({ 
  storage: storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB limit
  fileFilter: (req, file, cb) => {
    const filetypes = /jpeg|jpg|png/;
    const mimetype = filetypes.test(file.mimetype);
    const extname = filetypes.test(path.extname(file.originalname).toLowerCase());
    
    if (mimetype && extname) {
      return cb(null, true);
    }
    cb(new Error('Only JPEG/JPG/PNG images are allowed'));
  }
});

// Upload profile image
router.post('/image', authMiddleware, upload.single('image'), profileController.uploadProfileImage);

// Other routes remain the same...

// Get profile data
router.get('/', authMiddleware, profileController.getProfile);

// Update profile info (name, language)
router.put('/', authMiddleware, profileController.updateProfile);


// Delete profile image
router.delete('/image', authMiddleware, profileController.deleteProfileImage);

// Get available timezones
router.get('/timezones', authMiddleware, profileController.getTimezones);

// Update user timezone
router.put('/timezone', authMiddleware, profileController.updateTimezone);

module.exports = router;











// // routes\userProfileRoutes.js
// const express = require('express');
// const router = express.Router();
// const db = require('../config/db');
// const authMiddleware = require('../middleware/authMiddleware');

// // Get user profile information
// router.get('/profile', authMiddleware, async (req, res) => {
//   try {
//     const [users] = await db.promise().query(
//       `SELECT 
//         user_id as id,
//         first_name,
//         last_name,
//         email,
//         profile_image_path
//       FROM users 
//       WHERE user_id = ?`,
//       [req.user.id]
//     );

//     if (!users || users.length === 0) {
//       return res.status(404).json({ error: 'User not found' });
//     }

//     const user = users[0];
//     const response = {
//       id: user.id,
//       name: `${user.first_name} ${user.last_name}`,
//       email: user.email,
//       profileImage: user.profile_image_path,
//       initials: `${user.first_name.charAt(0)}${user.last_name.charAt(0)}`.toUpperCase(),
//       // Color can be generated based on user initials or ID for consistency
//       color: generateColorFromName(`${user.first_name} ${user.last_name}`)
//     };

//     res.status(200).json(response);
//   } catch (err) {
//     console.error('Profile error:', err);
//     res.status(500).json({ error: 'Server error' });
//   }
// });

// // Helper function to generate a consistent color from a name
// function generateColorFromName(name) {
//   // Simple hash function to convert name to a color
//   let hash = 0;
//   for (let i = 0; i < name.length; i++) {
//     hash = name.charCodeAt(i) + ((hash << 5) - hash);
//   }
  
//   const hue = Math.abs(hash % 360);
//   return `hsl(${hue}, 70%, 60%)`; // Return HSL color with fixed saturation and lightness
// }

// module.exports = router;