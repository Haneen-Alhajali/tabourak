import { google } from 'googleapis';

export const getCalendarDetails = async (accessToken) => {
  const auth = new google.auth.OAuth2();
  auth.setCredentials({ access_token: accessToken });

  const calendar = google.calendar({ version: 'v3', auth });
  const profile = await google.oauth2('v2').userinfo.get({ auth });

  const calendarList = await calendar.calendarList.list();

  const availableCalendars = calendarList.data.items?.map(c => c.id) ?? [];
  const calendarsForCheck = availableCalendars.filter(id => !id.includes('#holiday@')); 

  return {
    primaryEmail: profile.data.email,
    availableCalendars,
    calendarsForCheck,
  };
};
