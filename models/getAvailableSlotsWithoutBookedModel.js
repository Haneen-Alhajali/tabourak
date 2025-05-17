const db = require('../config/db');
const util = require('util');
const execute = util.promisify(db.execute).bind(db);

const availabilityModel = require('../models/bookingAvailabilityModel');

exports.getAvailableSlotsWithoutBooked = async (scheduleId, appointmentId, duration) => {
  const available = await availabilityModel.getAvailabilityForTwoWeeks(scheduleId);

  const bookedMeetings = await execute(
    `SELECT start_time, end_time FROM meetings WHERE appointment_id = ?`,
    [appointmentId]
  );

  const bookedSet = new Set(
    bookedMeetings.map(m => `${m.start_time.toISOString()}|${m.end_time.toISOString()}`)
  );

  const filtered = available.map(day => {
    if (!day.slots || day.slots.length === 0) return { ...day, slots: [] };

    const slots = [];

    day.slots.forEach(slot => {
      const start = new Date(`${day.date}T${slot.start_time}`);
      const end = new Date(`${day.date}T${slot.end_time}`);

      const totalMinutes = (end.getTime() - start.getTime()) / 60000;
      const numChunks = Math.floor(totalMinutes / duration);

      for (let i = 0; i < numChunks; i++) {
        const chunkStart = new Date(start.getTime() + i * duration * 60000);
        const chunkEnd = new Date(chunkStart.getTime() + duration * 60000);

        const key = `${chunkStart.toISOString()}|${chunkEnd.toISOString()}`;
        if (!bookedSet.has(key)) {
          slots.push({
            start_time: chunkStart.toISOString(),
            end_time: chunkEnd.toISOString()
          });
        }
      }
    });

    return {
      date: day.date,
      type: day.type,
      slots: slots,
    };
  });

  return filtered;
};
