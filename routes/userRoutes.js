// routes/userRoutes.js
const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');

router.get('/', authMiddleware, (req, res) => {
  res.status(200).json({
    name: req.user.name,
    email: req.user.email
  });
});

module.exports = router;