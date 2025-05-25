const db = require('../config/db'); // ملف الاتصال بقاعدة البيانات

const getMemberDetailsById = async (memberId) => {
  const [rows] = await db.query(
    `
    SELECT u.first_name, u.last_name, u.email
    FROM members m
    JOIN users u ON m.user_id = u.user_id
    WHERE m.member_id = ?
    `,
    [memberId]
  );
  return rows[0]; 
};

module.exports = {
  getMemberDetailsById,
};
