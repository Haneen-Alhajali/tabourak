// routes/authRoutes.js
const express = require('express');
const router = express.Router();
const authController = require('../../controllers/shahdController/authController');


router.post('/register', authController.register);
router.post('/login', authController.loginUser);
router.post('/google', authController.googleLogin);


module.exports = router;
