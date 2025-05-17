const db = require('../config/db').promise();

exports.saveAnswer = async (user_id, meeting_id, field_id, response_text) => {
  const [result] = await db.execute(
    `INSERT INTO custom_field_responses (user_id, meeting_id, field_id, response_text)
     VALUES (?, ?, ?, ?)`,
    [user_id, meeting_id, field_id, response_text]
  );

  return result.insertId;
};
