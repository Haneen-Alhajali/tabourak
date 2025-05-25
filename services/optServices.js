const otpGenerator = require("otp-generator");
const crypto = require("crypto");
const key = "123test";
const emailService = require("./emailerServices");

async function sendOTP(params, callback) {
  const otp = otpGenerator.generate(4, {
    digits: true,
  });

  const ttl = 5 * 60 * 1000;
  const expires = Date.now() + ttl;
  const data = `${params.email}.${otp}.${expires}`;

  const hash = crypto.createHmac("sha256", key).update(data).digest("hex");
  const fullHash = `${hash}.${expires}`;

  const otpMessage = `
  <div style="font-family: Arial, sans-serif; font-size: 16px;">
    Hello 👋, your OTP is
    <span style="font-weight: bold; font-size: 18px; color: #000;">${otp}</span> 
     . Please don't share this with anyone.
  </div>
`;

  var model = {
    email: params.email,
    subject: "Registration OTP",
    body: otpMessage,
  };

  emailService.sendEmail(model, (error, result) => {
    if (error) return callback(error);

    return callback(null, fullHash);
  });
}

async function verifyOTP(params, callback) {
  let [hashValue, expires] = params.hash.split(".");

  let now = Date.now();

  if (now > parseInt(expires)) return callback("OTP Expired");

  let data = `${params.email}.${params.otp}.${expires}`;
  let newCalculatedHash = crypto
    .createHmac("sha256", key)
    .update(data)
    .digest("hex");

  if (newCalculatedHash === hashValue) {
    return callback(null, "Success");
  }

  return callback("Invalid OTP");
}





async function sendCustomMessage(data, callback) {
  const confirmUrl = `http://192.168.1.115:3000/api/booking/${data.bookingId}/confirm`;
  const cancelUrl = `http://192.168.1.115:3000/api/booking/${data.bookingId}/cancel`;

  console.log("💡💡💡💡💡💡data.bookingId"+data.bookingId);
  const startTime = data.startTime;
  const endTime = data.endTime;
  const title = data.appointmentName;
  const details = encodeURIComponent("Thank you for booking. See you soon!");
  const location = data.locationLine;
  console.log("💡💡💡💡💡💡sendCustomMessage");

  const calendarUrl = `https://www.google.com/calendar/render?action=TEMPLATE&text=${title}&dates=${startTime}/${endTime}&details=${details}&location=${location}`;

  const calendarButton = `
    <div style="margin-top: 20px;">
      <a href="${calendarUrl}" target="_blank" style="display: inline-block; padding: 10px 20px; background-color:rgb(23, 194, 180); color: white; text-decoration: none; border-radius: 4px;">
        Add to Google calendar
      </a>
    </div>
  `;


  const confirmationButtons = `
  <div style="margin-bottom: 20px;">
    <p style="font-size: 18px;">Would you like to confirm your booking?</p>
    <a href="${confirmUrl}" target="_blank" style="margin-right: 10px; padding: 10px 20px; background-color:rgb(0, 0, 0); color:white; text-decoration:none; border-radius:4px;">
      ✅ Confirm
    </a>
    <a href="${cancelUrl}" target="_blank" style="padding: 10px 20px; background-color:rgb(0, 0, 0); color:white; text-decoration:none; border-radius:4px;">
      ❌ Cancel
    </a>
  </div>
    <hr>

`;



const messageBody = `
  ${confirmationButtons}
  ${data.message}
  ${calendarButton}
`;


/*
  const messageBody = `
    ${data.message}
    ${calendarButton}
  `;
*/
  const model = {
    email: data.email,
    subject: data.subject,
    body: messageBody,
  };

  emailService.sendEmail(model, (error, result) => {
    if (error) return callback(error);
    return callback(null, result);
  });
}

module.exports = {
  sendOTP,
  verifyOTP,
  sendCustomMessage,
};
