const { CloudinaryStorage } = require('multer-storage-cloudinary');
const multer = require('multer');
const cloudinary = require('../config/cloudinary');
const path = require('path');

const storage = new CloudinaryStorage({
  cloudinary,
  params: (req, file) => ({
    folder: 'tabourak_responses',
    resource_type: 'raw',  
    format: 'pdf', 
    public_id: path.parse(file.originalname).name, 
    use_filename: true,
    unique_filename: false,
    access_mode: 'public'

  })
});

const upload = multer({ storage });

module.exports = upload;
