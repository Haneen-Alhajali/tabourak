const express = require('express');
const router = express.Router();
const { getMemberById } = require('../../controllers/shahdController/memberController');

router.get('/members/:id', getMemberById);

module.exports = router;
