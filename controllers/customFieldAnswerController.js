const customFieldResponseModel = require('../models/customFieldAnswerModel');

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
