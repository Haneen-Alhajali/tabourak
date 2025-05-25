const db = require('../config/db').promise();

exports.saveAnswer = async (user_id, meeting_id, field_id, response_text) => {
  const [result] = await db.execute(
    `INSERT INTO custom_field_responses (user_info_id, meeting_id, field_id, response_text)
     VALUES (?, ?, ?, ?)`,
    [user_id, meeting_id, field_id, response_text]
  );

  return result.insertId;
};


exports.createUserInfo = async (firstName, lastName, email) => {
  const [result] = await db.execute(
    `INSERT INTO intake_form_user_info (first_name, last_name, email)
     VALUES (?, ?, ?)`,
    [firstName, lastName, email]
  );
  return result.insertId;
};


exports.createMeeting = async ({
  appointment_id,
  staff_id,
  user_info_id,
  organization_id,
  start_time,
  end_time,
  timezone,
  notes,
  payment_status,
  amount,
  currency,
  payment_id,
}) => {
  
  const [result] = await db.execute(
    `INSERT INTO meetings (
      appointment_id,
      staff_id,
      user_info_id,
      organization_id,
      start_time,
      end_time,
      timezone,
      notes,
      payment_status,
      amount,
      currency,
      payment_id
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    [
      appointment_id,
      staff_id,
      user_info_id,
      organization_id,
      start_time,
      end_time,
      timezone,
      notes || null,
      payment_status || null,
      amount || null,
      currency || null,
      payment_id || null,
    ]
  );

  return result.insertId;
};

