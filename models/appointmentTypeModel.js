// models/appointmentTypeModel.js
const db = require('../config/db');

class AppointmentType {
  static async createDefaults(userId) {
    console.log('DEBUG: Creating defaults for user ID:', userId);
    // 1. Create organization
    const [org] = await db.promise().query(
      'INSERT INTO organizations (name) VALUES (?)',
      [`User ${userId}'s Organization`]
    );
    console.log('DEBUG: Organization created with ID:', org.insertId);
    
    // 2. Add user to organization
    await db.promise().query(
      'INSERT INTO members (user_id, organization_id, role) VALUES (?, ?, ?)',
      [userId, org.insertId, 'owner']
    );
    console.log('DEBUG: User added to organization as owner');
    
    // 3. Create default types
    const defaultTypes = [
      ['At a place', 'in_person', 60, true],
      ['Web conference', 'video_call', 60, true],
      ['Phone call', 'phone_call', 30, false]
    ];
    console.log('DEBUG: Creating default appointment types');
    
    await db.promise().query(
      `INSERT INTO appointment_types 
      (organization_id, name, meeting_type, duration_minutes, is_active)
      VALUES ?`,
      [defaultTypes.map(type => [org.insertId, ...type])]
    );
    console.log('DEBUG: Default appointment types created');
    
    return { organizationId: org.insertId };
  }

  static async getUserTypes(userId) {
    console.log('DEBUG: Getting appointment types for user ID:', userId);
    const [types] = await db.promise().query(
      `SELECT at.* FROM appointment_types at
      JOIN members m ON at.organization_id = m.organization_id
      WHERE m.user_id = ?`,
      [userId]
    );
    console.log('DEBUG: Found', types.length, 'appointment types');
    return types;
  }

  static async updatePreferences(userId, preferences) {
    console.log('DEBUG: Updating preferences for user ID:', userId);
    console.log('DEBUG: New preferences:', preferences);
    // Get user's organization
    const [org] = await db.promise().query(
      `SELECT organization_id FROM members 
      WHERE user_id = ? LIMIT 1`,
      [userId]
    );
    
    if (!org[0]) {
      console.log('DEBUG: Organization not found for user ID:', userId);
      throw new Error('Organization not found');
    }
    
    console.log('DEBUG: Found organization ID:', org[0].organization_id);
    // Update each type
    for (const pref of preferences) {
      console.log('DEBUG: Updating preference for type:', pref.type);
      await db.promise().query(
        `UPDATE appointment_types 
        SET is_active = ?
        WHERE organization_id = ? AND meeting_type = ?`,
        [pref.isSelected, org[0].organization_id, pref.type]
      );
    }
    
    console.log('DEBUG: Preferences updated successfully');
    return { success: true };
  }
}

module.exports = AppointmentType;
