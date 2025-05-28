const express = require('express');
const router = express.Router();
const customFieldResponseController = require('../../controllers/shahdController/customFieldAnswerController');

router.post('/custom-field-response', customFieldResponseController.submitAnswer);

router.post('/intake-form-user', customFieldResponseController.createUserInfo);


router.post('/create-meeting-for-booking', customFieldResponseController.createMeeting);

router.get('/responses_user_info/:user_info_id', customFieldResponseController.getResponsesByUserInfoId);

module.exports = router;


