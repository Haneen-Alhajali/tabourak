const db = require('../config/db');

const createUser = (userData, callback) => {
  const { name, email, password } = userData;
  const sql = 'INSERT INTO users (name, email, password_hash) VALUES (?, ?, ?)';
  db.query(sql, [name, email, password], callback);
};


 const findUserByEmail=(email, callback)=>{
  const sql = 'SELECT * FROM users WHERE email = ?';
  db.query(sql, [email], (err, results) => {
    if (err) return callback(err);
    callback(null, results[0]); 
  });
 }


module.exports = { createUser ,findUserByEmail };
