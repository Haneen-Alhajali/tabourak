const db = require('../config/db');

const getMemberById = (req, res) => {
  const memberId = req.params.id;

  const query = `
    SELECT users.email, users.first_name, users.last_name
    FROM members
    JOIN users ON members.user_id = users.user_id
    WHERE members.member_id = ?
  `;

  db.query(query, [memberId], (err, results) => {
    if (err) {
      console.error('خطأ في جلب بيانات العضو:', err);
      return res.status(500).json({ message: 'حدث خطأ أثناء جلب بيانات العضو' });
    }

    if (results.length === 0) {
      return res.status(404).json({ message: 'لم يتم العثور على العضو' });
    }

    res.json(results[0]);
  });
};

module.exports = {
  getMemberById
};
