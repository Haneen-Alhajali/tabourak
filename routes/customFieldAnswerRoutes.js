const express = require('express');
const router = express.Router();
const customFieldResponseController = require('../controllers/customFieldAnswerController');

router.post('/custom-field-response', customFieldResponseController.submitAnswer);

module.exports = router;
