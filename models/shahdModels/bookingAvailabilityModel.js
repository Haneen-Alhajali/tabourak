const db = require('../../config/db');

const util = require('util');


const execute = util.promisify(db.execute).bind(db);

exports.getAvailabilityForTwoWeeks = async (scheduleId) => {
  const result = [];

  for (let i = 0; i < 14; i++) {
    const currentDate = new Date();
    currentDate.setDate(currentDate.getDate() + i);

    const dateStr = currentDate.toISOString().split('T')[0]; // YYYY-MM-DD

    console.log('dateStr:', dateStr);

    const dayOfWeek = currentDate.toLocaleDateString('en-US', { weekday: 'long' }).toLowerCase();

    // 1. Date-specific
    const specific = await execute(
      `SELECT * FROM date_specific_availability
       WHERE schedule_id = ? AND specific_date = ? AND is_available = TRUE`,
      [scheduleId, dateStr]
    );
    console.log('specific:', specific);

    if (specific.length > 0) {
      result.push({ date: dateStr, type: 'specific', slots: specific });
      continue;
    }

    // 2. Seasonal
    const seasonal = await execute(
      `SELECT s.*, ss.day_of_week, ss.start_time, ss.end_time FROM seasonal_availability s
       JOIN seasonal_availability_slots ss ON s.season_id = ss.season_id
       WHERE s.schedule_id = ? AND ? BETWEEN s.start_date AND s.end_date
         AND s.is_active = TRUE AND ss.day_of_week = ? AND ss.is_available = TRUE`,
      [scheduleId, dateStr, dayOfWeek]
    );

    if (seasonal.length > 0) {
      result.push({ date: dateStr, type: 'seasonal', slots: seasonal });
      continue;
    }

    // 3. Recurring
    const recurring = await execute(
      `SELECT * FROM recurring_availability
       WHERE schedule_id = ? AND day_of_week = ? AND is_available = TRUE`,
      [scheduleId, dayOfWeek]
    );
    if (recurring.length > 0) {
      result.push({ date: dateStr, type: 'recurring', slots: recurring });
    } else {
      result.push({ date: dateStr, type: 'unavailable', slots: [] });
    }
  }

  return result;
};
