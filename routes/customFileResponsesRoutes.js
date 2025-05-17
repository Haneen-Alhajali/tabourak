const express = require('express');
const router = express.Router();
const path = require('path');
const fs = require('fs');
const db = require('../config/db');
const cloudinary = require('../config/cloudinary');

const multer = require('multer');
const upload = multer({ dest: 'uploads/' });

// route
router.post('/upload-file-response', upload.single('file'), async (req, res) => {
  const { field_id, meeting_id, user_id } = req.body;

  if (!req.file) {
    return res.status(400).json({ error: 'File not uploaded' });
  }

  const filePath = req.file.path;
  const fileName = path.parse(req.file.originalname).name;

  try {
    const result = await cloudinary.uploader.upload(filePath, {
      folder: 'tabourak_responses',
      resource_type: 'raw',  
      public_id: fileName,
      use_filename: true,
      unique_filename: false
    });

    fs.unlinkSync(filePath);

    const fileUrl = `https://docs.google.com/gview?url=${result.secure_url}`;

    const sql = `
      INSERT INTO custom_field_responses (field_id, meeting_id, user_id, response_text)
      VALUES (?, ?, ?, ?)
    `;

    db.query(sql, [field_id, meeting_id, user_id, fileUrl], (err, results) => {
      if (err) {
        console.error("❌ DB Error:", err);
        return res.status(500).json({ error: 'Database error' });
      }

      res.json({
        message: 'File uploaded and link saved',
        file_url: fileUrl,
      });
    });

  } catch (err) {
    console.error("❌ Cloudinary Upload Error:", err);
    res.status(500).json({ error: 'Upload failed' });
  }
});

module.exports = router;
