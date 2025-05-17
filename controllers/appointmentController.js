const appointmentModel = require("../models/appointmentModel");
const { updateAppointmentById } = require("../models/appointmentModel");

const getAppointmentDetails = (req, res) => {
  const appointmentId = req.params.id;

  appointmentModel.getAppointmentById(appointmentId, (err, result) => {
    if (err) {
      console.error("Error fetching appointment:", err);
      return res.status(500).json({ error: "Internal Server Error" });
    }

    if (!result) {
      return res.status(404).json({ message: "Appointment not found" });
    }

    const { meeting_type, video_provider, meeting_phone, location } = result;
    if (meeting_type === "video_call") {
      return res.status(200).json({ message: "Meeting type: Zoom video call" });
    }
    if (meeting_type === "phone_call") {
      if (!meeting_phone) {
        return res
          .status(200)
          .json({
            message: "Phone number not provided for phone call meeting.",
          });
      } else {
        return res
          .status(200)
          .json({ message: "Phone call meeting", phone: meeting_phone });
      }
    }
    if (meeting_type === "in_person") {
      if (!location) {
        return res
          .status(200)
          .json({ message: "Location not provided for in-person meeting." });
      } else {
        return res
          .status(200)
          .json({
            message: "In-person meeting at the following location",
            location,
          });
      }
    }

    // 4. Fallback if no condition matches
    return res
      .status(200)
      .json({ message: "Appointment details", data: result });
  });
};

const updateAppointmentDetails = (req, res) => {
  const appointmentId = req.params.id;
  const { meeting_type, meeting_phone, location } = req.body;

  if (!meeting_type) {
    return res.status(400).json({ message: "Meeting type is required" });
  }

  updateAppointmentById(
    appointmentId,
    { meeting_type, meeting_phone, location },
    (err, result) => {
      if (err) {
        console.error("Error updating appointment:", err);
        return res.status(500).json({ error: "Internal Server Error" });
      }

      if (result.affectedRows === 0) {
        return res.status(404).json({ message: "Appointment not found" });
      }

      res.status(200).json({ message: "Appointment updated successfully" });
    }
  );
};

const getAppointmentsByPage = async (req, res) => {
  const pageId = req.params.pageId;

  try {
    const appointments = await appointmentModel.getAppointmentsByPageId(pageId);
    res.status(200).json(appointments);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Error fetching appointments" });
  }
};

module.exports = {
  getAppointmentDetails,
  updateAppointmentDetails,
  getAppointmentsByPage,
};
