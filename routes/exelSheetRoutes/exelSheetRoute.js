const express = require('express');
const router = express.Router();
const responseController = require('../../controllers/exelSheetController/exelSheetController');

router.get('/export/:meetingId', responseController.exportResponsesToCSV);

module.exports = router;
