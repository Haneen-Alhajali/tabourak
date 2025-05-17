const db = require('../config/db').promise();

exports.createOptions = async (field_id, options) => {
  const promises = options.map((opt, index) =>
    db.execute(
      `INSERT INTO custom_field_options (field_id, option_value, display_order)
       VALUES (?, ?, ?)`,
      [field_id, opt, index]
    )
  );
  await Promise.all(promises);
};

exports.deleteOptionsByFieldId = async (field_id) => {
  await db.execute(`DELETE FROM custom_field_options WHERE field_id = ?`, [field_id]);
};

exports.updateOrInsertOptions = async (field_id, options) => {
  const updateOrInsertPromises = options.map(async (opt, index) => {

      await db.execute(
        `UPDATE custom_field_options 
         SET option_value = ?, display_order = ?
         WHERE option_id = ? AND field_id = ?`,
        [opt.option_value, index, opt.option_id, field_id]
      );
  
  });

  await Promise.all(updateOrInsertPromises);
};

