const db = require('../config/db').promise();

exports.createCustomField = async (fieldData) => {
  const [result] = await db.execute(
    `INSERT INTO custom_fields 
      (appointment_id, label, type, is_required, help_text, display_order, default_value) 
     VALUES (?, ?, ?, ?, ?, ?, ?)`,
    [
      fieldData.appointment_id,
      fieldData.label,
      fieldData.type,
      fieldData.is_required || false,
      fieldData.help_text || null,
      fieldData.display_order || 0,
      fieldData.default_value || null,
    ]
  );
  console.log("🔎 db.execute resultRaw:", result);
  return result.insertId;
};

exports.deleteCustomField = async (field_id) => {
  await db.execute(`DELETE FROM custom_fields WHERE field_id = ?`, [field_id]);
};

exports.getCustomFieldsByAppointmentId = async (appointmentId) => {
  const [fields] = await db.execute(
    `SELECT * FROM custom_fields WHERE appointment_id = ? ORDER BY display_order ASC`,
    [appointmentId]
  );

  for (let field of fields) {
    const [options] = await db.execute(
      `SELECT option_id, option_value, display_order 
       FROM custom_field_options 
       WHERE field_id = ? ORDER BY display_order ASC`,
      [field.field_id]
    );
    field.options = options;
  }

  return fields;
};


exports.updateCustomField = async (fieldId, updatedData) => {

  
  await db.execute(
    `UPDATE custom_fields 
     SET label = ?, type = ?, is_required = ?, help_text = ?, display_order = ?, default_value = ?
     WHERE field_id = ?`,
    [
      updatedData.label,
      updatedData.type,
      updatedData.is_required || false,
      updatedData.help_text || null,
      updatedData.display_order || 0,
      updatedData.default_value || null,
      fieldId
    ]
  );
};



exports.getCustomFieldById = async (fieldId) => {
  const [fields] = await db.execute(
    `SELECT * FROM custom_fields WHERE field_id = ?`,
    [fieldId]
  );

  if (fields.length === 0) return null;

  const field = fields[0];

  const [options] = await db.execute(
    `SELECT option_id, option_value, display_order
     FROM custom_field_options
     WHERE field_id = ? ORDER BY display_order ASC`,
    [field.field_id]
  );

  field.options = options;
  return field;
};


exports.updateFieldOrder = async (fieldId, order) => {
  await db.execute(
    `UPDATE custom_fields SET display_order = ? WHERE field_id = ?`,
    [order, fieldId]
  );

};
 