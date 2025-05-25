const customFieldResponseModel = require('../models/customFieldAnswerModel');
const db = require('../config/db').promise();

exports.submitAnswer = async (req, res) => {
  try {
    const { user_id, meeting_id, field_id, response_text } = req.body;

    if (!user_id || !meeting_id || !field_id || !response_text) {
      return res.status(400).json({ error: "user_id, meeting_id, field_id and response_text are required" });
    }

    const responseId = await customFieldResponseModel.saveAnswer(user_id, meeting_id, field_id, response_text);

    res.status(201).json({ message: "Answer saved successfully", responseId });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to save answer" });
  }
};

//for creat uzer for form rezponce
exports.createUserInfo = async (req, res) => {
  try {
    const { first_name, last_name, email } = req.body;

    if (!first_name || !last_name || !email) {
      return res.status(400).json({ error: "first_name, last_name, and email are required" });
    }

    const userId = await customFieldResponseModel.createUserInfo(first_name, last_name, email);

    res.status(201).json({
      message: "User info created successfully",
      user_info_id: userId,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to create user info" });
  }
};




exports.createMeeting = async (req, res) => {
  try {

    const {
      appointment_id,
      staff_id,
      user_info_id,
      organization_id,
      start_time, // 
      end_time,   
      timezone,
      notes,
      payment_status,
      amount,
      currency,
      payment_id,
    } = req.body;

    
    if (
      !appointment_id ||
      !staff_id ||
      !user_info_id ||
      !organization_id ||
      !start_time ||
      !end_time ||
      !timezone
    ) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const meetingId = await customFieldResponseModel.createMeeting({
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
    });

    console.log("📦📦📦"+  appointment_id +"  "
      +staff_id  +"  "
      +user_info_id  +"  "
      +organization_id  +"  "
      +start_time  +"  "
      +end_time  +"  "
      +timezone);
    res.status(201).json({
      message: 'Meeting created successfully',
      meeting_id: meetingId,
    });
  } catch (err) {
    console.error('Error creating meeting:', err);
    res.status(500).json({ error: 'Failed to create meeting' });
  }
};



///////////////////////////////////////////////////////////
exports.getResponsesByUserInfoId = async (req, res) => {
  const { user_info_id } = req.params;
  try {
    const [rows] = await db.execute(
      `SELECT cfr.response_text, cf.label
       FROM custom_field_responses cfr
       JOIN custom_fields cf ON cfr.field_id = cf.field_id
       WHERE cfr.user_info_id = ?`,
      [user_info_id]
    );

    res.status(200).json(rows);
  } catch (error) {
    console.error('Error fetching responses:', error);
    res.status(500).json({ error: 'Server error' });
  }
};