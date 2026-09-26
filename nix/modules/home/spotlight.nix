{ ... }:

{
  programs.nix-plist-manager = {
    enable = true;
    options.applications.systemSettings.spotlight.searchResults = {
      appStore = true;
      apps = true;
      books = true;
      calculator = true;
      calendar = true;
      contacts = true;
      dictionary = true;
      files = true;
      folders = true;
      games = true;
      iPhoneApps = true;
      mail = true;
      menuItems = true;
      messages = true;
      music = true;
      notes = true;
      phone = true;
      photos = true;
      podcasts = true;
      reminders = true;
      safari = true;
      shortcuts = true;
      systemSettings = true;
      tips = true;
      voiceMemos = true;
    };
  };
}
