const otpController=require("../../controllers/shahdController/otpController");
 
const express = require('express');
const router = express.Router();
router.post("/otp-login",otpController.otpLogin);
router.post("/otp-verify",otpController.verifyOTP);

router.post("/send-email", otpController.sendMessage);

module.exports= router;
