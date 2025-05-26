const db = require("../../config/db");
const util = require("util");
const execute = util.promisify(db.execute).bind(db);

const availabilityModel = require("../shahdModels/bookingAvailabilityModel");
//const availabilityModel = require("../models/bookingAvailabilityModel");

exports.getAvailableSlotsWithoutBooked = async (
  scheduleId,
  appointmentId,
  duration
) => {
  const available = await availabilityModel.getAvailabilityForTwoWeeks(
    scheduleId
  );

  const bookedMeetings = await execute(
    `SELECT start_time, end_time FROM meetings WHERE appointment_id = ?`,
    [appointmentId]
  );

  console.log(
    "📦📦📦📦📦📦📦 appointmentId "+appointmentId);


  console.log(
    "✅✅✅✅✅✅✅✅✅bookedMeetings",
    JSON.stringify(bookedMeetings, null, 2)
  );

  // Create a Set with consistent time formatting (UTC)
  const bookedSet = new Set(
    bookedMeetings.map(m => {
      // Parse the UTC times from database and format consistently
      const start = new Date(m.start_time).toISOString();
      const end = new Date(m.end_time).toISOString();
      console.log("💡💡💡💡 start bookedSet", start);
      console.log("💡💡💡💡 end bookedSet", end);

      return `${start}|${end}`;
    })
  );

  console.log("✅✅✅✅✅✅✅✅✅ bookedSet", Array.from(bookedSet));


  const filtered = available.map((day) => {
    if (!day.slots || day.slots.length === 0) return { ...day, slots: [] };
    const slots = [];

    day.slots.forEach((slot) => {
      // Create dates in local time (Israel time)
      const start = new Date(`${day.date}T${slot.start_time}+03:00`);
      const end = new Date(`${day.date}T${slot.end_time}+03:00`);

      const totalMinutes = (end.getTime() - start.getTime()) / 60000;
      const numChunks = Math.floor(totalMinutes / duration);

      for (let i = 0; i < numChunks; i++) {
        const chunkStart = new Date(start.getTime() + i * duration * 60000);
        const chunkEnd = new Date(chunkStart.getTime() + duration * 60000);

        // Format both in UTC for comparison with bookedSet
        const key = `${chunkStart.toISOString()}|${chunkEnd.toISOString()}`;

        if (!bookedSet.has(key)) {
          slots.push({
            // Return times in local format (Israel time)
            start_time: formatLocalTime(chunkStart),
            end_time: formatLocalTime(chunkEnd),
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

  console.log(
    "✅✅✅✅✅✅✅✅✅✅ filtered",
    JSON.stringify(filtered, null, 2)
  );

  return filtered;
};

// Format date in local Israel time (GMT+0300)
function formatLocalTime(date) {
  // Convert to Israel time by adding 3 hours (since JS Dates are UTC)
  const israelTime = new Date(date.getTime() + 3 * 60 * 60 * 1000);
  return israelTime.toISOString().slice(0, 19).replace('T', ' ');
}

