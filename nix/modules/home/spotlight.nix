{ ... }:

{
  programs.nix-plist-manager = {
    enable = true;
    options.applications.systemSettings.spotlight.searchResults = {
      appStore = false;
      apps = true;
      books = true;
      calculator = true;
      calendar = true;
      contacts = true;
      dictionary = false;
      files = true;
      folders = true;
      games = false;
      iPhoneApps = false;
      mail = true;
      menuItems = true;
      messages = true;
      music = true;
      notes = true;
      phone = true;
      photos = true;
      podcasts = true;
      reminders = true;
      safari = false;
      shortcuts = true;
      systemSettings = true;
      tips = false;
      voiceMemos = true;
    };
  };
}
