const db = require('../../config/db');

const createUser = (userData, callback) => {
  const { first_name, last_name, email, password, role } = userData;
  const sql = 'INSERT INTO users (first_name, last_name, email, password_hash, role) VALUES (?, ?, ?, ?, ?)';
  db.query(sql, [first_name, last_name, email, password, role], callback);
};


 const findUserByEmail=(email, callback)=>{
  const sql = 'SELECT * FROM users WHERE email = ?';
  db.query(sql, [email], (err, results) => {
    if (err) return callback(err);
    callback(null, results[0]); 
  });
 }


module.exports = { createUser ,findUserByEmail };
