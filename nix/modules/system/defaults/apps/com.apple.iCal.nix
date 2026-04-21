{ ... }:

# Calendar.app preferences
{
  system.defaults.CustomUserPreferences = {
    "com.apple.iCal" = {
      # Days per week
      "n days of week" = 7;

      # First day of week: 0 = system setting, 1 = Sunday, 2 = Monday, ... 7 = Saturday
      "first day of week" = 0;

      # Scroll in week view by: 0 = day, 1 = week, 2 = week (stop on today)
      "scroll by weeks in week view" = 1;

      # Show week numbers in the calendar view
      "Show Week Numbers" = 1;

      # Show a timezone selector in the toolbar; allows events to have their own timezone
      "TimeZone support enabled" = 1;

      # Work hours: 360 = 06:00, 480 = 08:00
      "first minute of work hours" = 360;

      # Work hours: 1080 = 18:00, 1200 = 20:00
      "last minute of work hours" = 1080;

      # Show 16 hours at a time (default: 12)
      "number of hours displayed" = 16;

      "display birthdays calendar" = true;
    };
  };
}
