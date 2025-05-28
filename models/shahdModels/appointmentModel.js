const db = require("../../config/db");

const getAppointmentById = (id, callback) => {
  const sql = `
    SELECT meeting_type, meeting_phone, location 
    FROM appointments 
    WHERE appointment_id = ?
  `;
  db.query(sql, [id], (err, results) => {
    if (err) return callback(err);
    callback(null, results[0]);
  });
};

const updateAppointmentById = (id, data, callback) => {
  const { meeting_type, meeting_phone, location } = data;

  const sql = `
    UPDATE appointments 
    SET meeting_type = ?, meeting_phone = ?, location = ?, updated_at = CURRENT_TIMESTAMP
    WHERE appointment_id = ?
  `;

  db.query(sql, [meeting_type, meeting_phone, location, id], (err, result) => {
    if (err) return callback(err);
    callback(null, result);
  });
};

const getAppointmentsByPageId = (pageId) => {
  return new Promise((resolve, reject) => {
    const query = `
      SELECT * FROM appointments
      WHERE page_id = ?
    `;
    db.query(query, [pageId], (err, results) => {
      if (err) reject(err);
      else resolve(results);
    });
  });
};

module.exports = {
  getAppointmentById,
  updateAppointmentById,
  getAppointmentsByPageId,
};
