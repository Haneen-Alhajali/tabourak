const responseService = require('../../../services/exelSheetServices/exelSheetService');
const { format } = require('@fast-csv/format');

exports.exportResponsesToCSVByMember = async (req, res) => {
  const memberId = req.params.memberId;

  try {
    const responses = await responseService.getResponsesByMemberId(memberId);

    const groupedResponses = {};
    const allLabelsSet = new Set();

    responses.forEach(resp => {
      const userKey = `${resp.user_info_id}_${resp.start_time}`;

      if (!groupedResponses[userKey]) {
        groupedResponses[userKey] = {
          'Full Name': `${resp.first_name} ${resp.last_name}`,
          'Email': resp.email,
          'Appointment Name': resp.appointment_name,
          'Meeting Date': new Date(resp.start_time).toLocaleString('en-US', { timeZone: resp.timezone }),
          'Created At': new Date(resp.created_at).toLocaleString('en-US', { timeZone: resp.timezone }),
        };
      }

      groupedResponses[userKey][resp.label] = resp.response_text;
      allLabelsSet.add(resp.label);
    });

    const allLabels = Array.from(allLabelsSet);
    const headers = ['Full Name', 'Email', 'Appointment Name', 'Meeting Date', ...allLabels, 'Created At'];

    res.setHeader('Content-Disposition', `attachment; filename=responses_member_${memberId}.csv`);
    res.setHeader('Content-Type', 'text/csv');

    const csvStream = format({ headers });
    csvStream.pipe(res);

    Object.values(groupedResponses).forEach(userData => {
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








































/*
exports.exportResponsesToCSV = async (req, res) => {
  const pageId = req.params.pageId;

  try {
    const responses = await responseService.getResponsesByPageId(pageId);

    const groupedResponses = {};
    const allLabelsSet = new Set();

    responses.forEach(resp => {
      const userKey = `${resp.user_info_id}`;

      if (!groupedResponses[userKey]) {
        groupedResponses[userKey] = {
          'User Name': `${resp.first_name} ${resp.last_name}`,
          'Email': resp.email,
          'Meeting Name': resp.appointment_name,
          'Start Time': new Date(resp.start_time).toLocaleString('en-US', { timeZone: resp.timezone }),
          'Submit Date': new Date(resp.created_at).toLocaleString(),
        };
      }

      groupedResponses[userKey][resp.label] = resp.response_text;
      allLabelsSet.add(resp.label);
    });

    const allLabels = Array.from(allLabelsSet);
    const headers = ['User Name', 'Email', 'Meeting Name', 'Start Time', ...allLabels, 'Date Created'];

    res.setHeader('Content-Disposition', `attachment; filename=page_${pageId}_responses.csv`);
    res.setHeader('Content-Type', 'text/csv');

    const csvStream = format({ headers });
    csvStream.pipe(res);

    Object.values(groupedResponses).forEach(userData => {
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
};*/


























/*
exports.exportResponsesToCSV = async (req, res) => {
  const meetingId = req.params.meetingId;

  try {
    const responses = await responseService.getResponsesByMeeting(meetingId);

    const groupedResponses = {};
    const allLabelsSet = new Set();

    responses.forEach(resp => {
      if (!groupedResponses[resp.user_info_id]) {
        groupedResponses[resp.user_info_id] = {
          'User ID': resp.user_info_id,
          'Date Created': resp.created_at, 
        };
      }

      groupedResponses[resp.user_info_id][resp.label] = resp.response_text;
      allLabelsSet.add(resp.label);
    });

    const allLabels = Array.from(allLabelsSet); 
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
};*/
