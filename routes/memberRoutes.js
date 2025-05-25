const express = require('express');
const router = express.Router();
const { getMemberById } = require('../controllers/memberController');

router.get('/members/:id', getMemberById);

module.exports = router;
