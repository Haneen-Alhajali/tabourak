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

module.exports = {
  sendOTP,
  verifyOTP,
};
