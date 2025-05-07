//middleware\authMiddleware.js
const jwt = require('jsonwebtoken');
const db = require('../config/db');

module.exports = async (req, res, next) => {
  console.log('DEBUG: Entering auth middleware');
  try {
    // 1. Get token from header
    const token = req.header('Authorization')?.replace('Bearer ', '');
    console.log('DEBUG: Received token:', token ? '***' : null);
    if (!token) {
      console.log('No token provided');
      return res.status(401).json({ error: 'Please login first' });
    }

    // 2. Verify token
    let decoded;
    try {
      decoded = jwt.verify(token, process.env.JWT_SECRET);
      console.log('Decoded token:', decoded); // Debug log
    } catch (err) {
      console.log('Token verification failed:', err.message);
      return res.status(401).json({ error: 'Invalid token' });
    }

    // 3. Find user in database
    console.log('DEBUG: Looking for user ID in DB:', decoded.id);
    const [users] = await db.promise().query(
      'SELECT user_id, email, first_name, last_name FROM users WHERE user_id = ?',
      [decoded.id]
    );

    if (!users || users.length === 0) {
      console.log('User not found in database for ID:', decoded.id);
      return res.status(401).json({ error: 'User not found' });
    }

    // 4. Attach complete user object to request
    req.user = {
      id: users[0].user_id, // Use the exact database column name
      email: users[0].email,
      name: `${users[0].first_name} ${users[0].last_name}`
    };

    console.log('Authenticated user:', req.user); // Debug log
    console.log('DEBUG: Authentication successful, proceeding to next middleware');
    next();
  } catch (err) {
    console.error('Auth middleware error:', err);
    console.log('DEBUG: Auth middleware error:', err.message);
    res.status(500).json({ error: 'Authentication failed' });
  }
};
