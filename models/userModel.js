// models\userModel.js
const db = require('../config/db');

const createUser = (userData, callback) => {
  console.log('DEBUG: Creating user in database');
  const { first_name, last_name, email, password, role } = userData;
  const sql = 'INSERT INTO users (first_name, last_name, email, password_hash, role) VALUES (?, ?, ?, ?, ?)';
  console.log('DEBUG: Executing SQL:', sql);
  db.query(sql, [first_name, last_name, email, password, role], callback);
};


 const findUserByEmail=(email, callback)=>{
  console.log('DEBUG: Finding user by email:', email);
  const sql = `
  SELECT 
    user_id as id, 
    email, 
    CONCAT(first_name, ' ', last_name) as name,
    password_hash,
    phone
  FROM users 
  WHERE email = ?
`;
  console.log('DEBUG: Executing SQL:', sql.trim());
  db.query(sql, [email], (err, results) => {
    if (err) {
      console.log('DEBUG: Database error:', err);
      return callback(err);
    }
    console.log('DEBUG: Query results:', results.length ? 'user found' : 'no user found');
    callback(null, results[0]); 
  });
 }


module.exports = { createUser ,findUserByEmail };
// // models\userModel.js
// const db = require('../config/db');

// const createUser = (userData, callback) => {
//   const { first_name, last_name, email, password, role } = userData;
//   const sql = 'INSERT INTO users (first_name, last_name, email, password_hash, role) VALUES (?, ?, ?, ?, ?)';
//   db.query(sql, [first_name, last_name, email, password, role], callback);
// };


//  const findUserByEmail=(email, callback)=>{
//   const sql = `
//   SELECT 
//     user_id as id, 
//     email, 
//     CONCAT(first_name, ' ', last_name) as name,
//     password_hash,
//     phone
//   FROM users 
//   WHERE email = ?
// `;
//   db.query(sql, [email], (err, results) => {
//     if (err) return callback(err);
//     callback(null, results[0]); 
//   });
//  }


// module.exports = { createUser ,findUserByEmail };
