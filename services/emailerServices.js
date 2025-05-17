const nodemailer = require("nodemailer");

async function sendEmail(params, callback) {

  const transporter = nodemailer.createTransport({
    service: "gmail",
    auth: {
      user: "shadthabit@gmail.com",
      pass: "asnj ilvj gked awml",
      
      },
  });
  
  var mailOptions = {
    from: "shadthabit@gmail.com",
    to: params.email,
    subject: params.subject,
    html: params.body,
  };

  transporter.sendMail(mailOptions, function (error, info) {
    if (error) return callback(error);
    else {
      console.log("Message sent:", info);
      return callback(null, info.response);
    }
  });
}

module.exports = {
  sendEmail,
};
