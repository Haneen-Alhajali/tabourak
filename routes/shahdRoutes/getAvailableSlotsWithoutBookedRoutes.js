const express = require("express");
const router = express.Router();
const bookingAvailabilityModel = require("../../models/shahdModels/getAvailableSlotsWithoutBookedModel");

router.get("/availability/next-14-days-filtered", async (req, res) => {
  const { schedule_id, page_id, appointment_id, duration } = req.query;

  if (!schedule_id || !appointment_id || !duration) {
    return res
      .status(400)
      .json({ error: "schedule_id, appointment_id and duration are required" });
  }

  try {
    const result =
      await bookingAvailabilityModel.getAvailableSlotsWithoutBooked(
        schedule_id,
        page_id,
        appointment_id,
        parseInt(duration)
      );

    res.json(result);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
});

////////////////////////////////////////////////////////////////////////////////////////////////////
router.get("/availability/next-14-days-filtered-group", async (req, res) => {
  const { schedule_id, page_id, appointment_id, duration } = req.query;

  if (!schedule_id || !appointment_id || !duration) {
    return res
      .status(400)
      .json({ error: "schedule_id, appointment_id and duration are required" });
  }

  try {
    const result =
      await bookingAvailabilityModel.getGroupAvailableSlotsWithoutBooked(
        schedule_id,
        page_id,
        appointment_id,
        parseInt(duration)
      );

    res.json(result);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
});























module.exports = router;
