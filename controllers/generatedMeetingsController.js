const db = require("../config/db");
const dayjs = require("dayjs");
const utc = require("dayjs/plugin/utc");
dayjs.extend(utc);

const createGeneratedMeeting = async (req, res) => {
  try {
    const {
      booking_id,
      provider,
      join_url,
      meeting_code,
      password,
      start_url,
      startTime,
      appointment_id,
    } = req.body;
    console.log("🔴 Request Body:", req.body);

    const query = `
      INSERT INTO generated_meetings (
        booking_id, provider, join_url, meeting_code, password,
        start_url, startTime, appointment_id
      )
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    `;

    const values = [
      booking_id,
      provider,
      join_url,
      meeting_code,
      password,
      start_url,
      startTime,
      appointment_id,
    ];

    console.log("✅✅✅✅✅✅✅✅✅✅✅✅✅values  " + values);

    await db.execute(query, values);

    res.status(201).json({ message: "Generated meeting saved successfully" });
  } catch (error) {
    console.error("Error saving generated meeting:", error);
    res.status(500).json({ message: "Server error" });
  }
};

///////////////////////////////////////////////////////////////////////////////////////////////

const getJoinUrlByAppointment = async (req, res) => {
  const { appointment_id, startTime } = req.body;

  if (!appointment_id || !startTime) {
    return res
      .status(400)
      .json({ message: "appointment_id and startTime are required" });
  }

  try {
    console.log("📦📦appointment_id:", appointment_id);
    console.log("📦📦startTime:", startTime);

    db.query(
      "SELECT join_url FROM generated_meetings WHERE appointment_id = ? AND startTime LIKE ? LIMIT 1",
      [appointment_id, startTime],
      (err, results) => {
        if (err) {
          console.error("❌ Error fetching meeting:", err);
          return res.status(500).json({ message: "Server error" });
        }

        console.log("📋 results:", results);

        if (!results || results.length === 0) {
          return res.status(404).json({ message: "No meeting found" });
        }

        console.log("🧪 result:", results[0]);

        return res.status(200).json({ meeting: results[0] });
      }
    );
  } catch (error) {
    console.error("❌ Error fetching join_url:", error);
    return res.status(500).json({ message: "Server error" });
  }
};

//////////////////////////////////////////////////////////////////////////////////////////////


const getMeetingById = async (req, res) => {
  const { meeting_id } = req.query;

  if (!meeting_id) {
    return res.status(400).json({ message: "meeting_id is required" });
  }
  console.log("📋📋📋meeting_id " + meeting_id);

  try {
    db.query(
      "SELECT * FROM tabourak_db.generated_meetings WHERE meeting_id = ?",
      [meeting_id],
      (err, results) => {
        if (err) {
          console.error("❌ Error fetching meeting:", err);
          return res.status(500).json({ message: "Server error" });
        }

        console.log("📋 results:", results);

        if (!results || results.length === 0) {
          return res.status(404).json({ message: "No meeting found" });
        }

        return res.status(200).json({ meeting: results[0] });
      }
    );
  } catch (error) {
    console.error("❌ Error fetching meeting:", error);
    return res.status(500).json({ message: "Server error" });
  }
};

module.exports = {
  createGeneratedMeeting,
  getJoinUrlByAppointment,
  getMeetingById,
};
