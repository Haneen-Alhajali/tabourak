const { OAuth2Client } = require('google-auth-library');
const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID_WEB);

exports.verifyGoogleToken = async (accessToken) => {
  try {

    const ticket = await client.verifyIdToken({
      idToken: accessToken, 
      audience: process.env.GOOGLE_CLIENT_ID_WEB,
    });
    
    const payload = ticket.getPayload();
    console.log('Verified payload:', payload);
    return payload;
  } catch (error) {
    console.error('Google token verification error:', error);
    throw new Error('Invalid Google token: ' + error.message);
  }
};