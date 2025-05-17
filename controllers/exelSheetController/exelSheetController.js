const responseService = require('../../services/exelSheetServices/exelSheetService');
const { format } = require('@fast-csv/format');

exports.exportResponsesToCSV = async (req, res) => {
  const meetingId = req.params.meetingId;

  try {
    const responses = await responseService.getResponsesByMeeting(meetingId);

    // تجميع الردود بحسب user_id
    const groupedResponses = {};
    const allLabelsSet = new Set();

    responses.forEach(resp => {
      if (!groupedResponses[resp.user_id]) {
        groupedResponses[resp.user_id] = {
          'User ID': resp.user_id,
          'Date Created': resp.created_at, // يمكنك تحديث هذا إذا تبين أحدث تاريخ مثلاً
        };
      }

      groupedResponses[resp.user_id][resp.label] = resp.response_text;
      allLabelsSet.add(resp.label);
    });

    const allLabels = Array.from(allLabelsSet); // لجعل الترتيب ثابت
    const headers = ['User ID', ...allLabels, 'Date Created'];

    // تحضير CSV
    res.setHeader('Content-Disposition', `attachment; filename=meeting_${meetingId}_responses.csv`);
    res.setHeader('Content-Type', 'text/csv');

    const csvStream = format({ headers });
    csvStream.pipe(res);

    Object.values(groupedResponses).forEach(userData => {
      // نحرص على ترتيب البيانات حسب headers
      const row = {};
      headers.forEach(header => {
        row[header] = userData[header] || '';
      });
      csvStream.write(row);
    });

    csvStream.end();
  } catch (error) {
    console.error("🔴 Export error:", error);
    res.status(500).json({ message: 'Error exporting responses to CSV' });
  }
};
