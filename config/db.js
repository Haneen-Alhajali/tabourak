//config\db.js
/*const mysql = require('mysql2');

const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: process.env.DATABASE_PASSWORD,
  database: 'tabourak_db',
});

db.connect((err) => {
  if (err) throw err;
  console.log('Connected to MySQL');
});

module.exports = db;*/



const mysql = require('mysql2');


const db = mysql.createPool({
  host: 'localhost',
  user: 'root',
  password: process.env.DATABASE_PASSWORD,
  database: 'tabourak_db',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});


db.getConnection((err, connection) => {
  if (err) {
    console.error('❌ MySQL connection failed:', err.message);
  } else {
    console.log('✅ Connected to MySQL');
    connection.release(); 
  }
});

module.exports = db;
