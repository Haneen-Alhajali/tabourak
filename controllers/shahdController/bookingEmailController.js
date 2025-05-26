const db = require('../../config/db');

exports.cancelBooking = (req, res) => {
  const meetingId = req.params.bookingId;
  console.log("♻️♻️♻️♻️♻️meetingId "+meetingId);

  db.query('DELETE FROM meetings WHERE meeting_id = ?', [meetingId], (err, result) => {
    if (err) {
      console.error(err);
      return res.status(500).send('<h2 style="color:red;">❌ Error canceling booking.</h2>');
    }

    res.send(`
      <div style="text-align: center; margin-top: 100px; font-family: Arial;">
        <h1 style="color: #d9534f; font-size: 32px;">Your booking has been canceled.</h1>
      </div>
    `);
  });
};

exports.confirmBooking = (req, res) => {
  const meetingId = req.params.bookingId;
  console.log("♻️♻️♻️♻️♻️meetingId "+meetingId);

  db.query('UPDATE meetings SET status = ? WHERE meeting_id = ?', ['confirmed', meetingId], (err, result) => {
    if (err) {
      console.error(err);
      return res.status(500).send('<h2 style="color:red;">❌ Error confirming booking.</h2>');
    }

    res.send(`
      <div style="text-align: center; margin-top: 100px; font-family: Arial;">
        <h1 style="color: #5cb85c; font-size: 32px;">Your booking has been confirmed. Thank you! 🎉</h1>
      </div>
    `);
  });
};
