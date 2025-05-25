const express = require('express');
const router = express.Router();
const responseController = require('../../controllers/exelSheetController/exelSheetController');

//router.get('/export/:meetingId', responseController.exportResponsesToCSV);
//router.get('/export-by-page/:pageId', responseController.exportResponsesToCSV);
router.get('/export-by-member/:memberId', responseController.exportResponsesToCSVByMember);

module.exports = router;

