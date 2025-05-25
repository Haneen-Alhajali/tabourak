const otpService = require("../services/optServices");

exports.otpLogin = (req, res, next) => {
  otpService.sendOTP(req.body, (error, results) => {
    if (error) {
      return res.status(400).send({
        message: "error",
        data: error,
      });
    }

    return res.status(200).send({
      message: "error",
      data: results,
    });
  });
};

exports.verifyOTP = (req, res, next) => {
  otpService.verifyOTP(req.body, (error, results) => {
    if (error) {
      return res.status(400).send({
        message: "error",
        data: error,
      });
    }
    return res.status(200).send({
      message: "error",
      data: results,
    });
  });
};






///////////////////////


exports.sendMessage = (req, res, next) => {
  otpService.sendCustomMessage(req.body, (error, result) => {
    if (error) {
      return res.status(400).json({
        message: "فشل في إرسال الرسالة",
        error: error,
      });
    }

    return res.status(200).json({
      message: "تم إرسال الرسالة بنجاح",
      data: result,
    });
  });
};