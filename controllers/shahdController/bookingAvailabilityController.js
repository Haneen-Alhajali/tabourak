const availabilityModel = require('../../models/shahdModels/bookingAvailabilityModel');
//const availabilityModel = require('../models/bookingAvailabilityModel');

exports.getTwoWeeksAvailability = async (req, res) => {
  const { schedule_id } = req.query;

  if (!schedule_id) {
    return res.status(400).json({ message: 'Missing schedule_id' });
  }

  try {
    const result = await availabilityModel.getAvailabilityForTwoWeeks(schedule_id);
    res.json(result);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};
