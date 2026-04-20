{ ... }:

# Homebrew packages for machines with a GUI (display, window manager, apps).
# Import this module in the host file for any GUI machine.
{
  homebrew.brews = [
    "cristianoliveira/tap/aerospace-scratchpad" # aerospace, scratchpad
    "chrome-cli" # cli, control chrome via cli
    "displayplacer" # macos, arrange monitors
    "fileicon" # macos, manage icons
    "iconsur" # macos, fetch icons
    "infat" # macos, set default filetypes
    "kanata" # system, keyboard mapper
    "m1ddc" # hardware, monitor control
    "oschrenk/made/keyboard" # hardware, control keyboard brightness of macbooks
    "oschrenk/made/mission" # macos, task management
    "oschrenk/made/nightshift" # hardware, control Night Shift
    "oschrenk/made/wallpaper" # macos, set wallpaper
    "sketchybar" # macos, custom statusbar
    "spicetify-cli" # spotify ricing
    "xcodes" # xcode & runtimes manager
  ];

  homebrew.casks = [
    "1password" # password manager
    "aerospace" # window manager
    "alcove" # macos, notch helper
    "antinote" # notes with SoulverCore
    "arc" # chromium based browser
    "calibre" # ebook manager
    "discord" # discord client
    "firefox" # browser
    "ghostty" # terminal
    "google-chrome" # browser
    "handbrake-app" # video transcoder
    "hex-fiend" # hex editor
    "huggingchat" # chat client for local llm
    "iina" # video client
    "intellij-idea" # jetbrains ide
    "jdk-mission-control" # monitor java applications
    "jdownloader" # download manager
    "johannesnagl/tap/showmd" # markdown preview
    "karabiner-elements" # customize keyboard
    "keyboardcleantool" # disables keyboard for cleaning
    "keycastr" # shows key strokes on screen
    "knockknock" # identify background tasks/processes
    "lulu" # firewall, block unknown outgoing connections
    "mochi" # study notes and flashcards
    "monodraw" # draw ascii diagrams
    "neovide-app" # neovim desktop app
    "numi" # calculator
    "obsidian" # notes
    "omnidisksweeper" # cleanup disk space
    "onyx" # macos maintenance
    "openoats" # meeting note-taker, transcribes calls
    "oschrenk/personal/mud" # markdown viewer
    "pika" # color picker
    "shortcat" # macos, vim picker
    "signal" # signal messaging
    "slack" # slack office communication
    "spotify" # audio client
    "tailscale-app" # vpn, mesh network
    "telegram" # telegram messaging
    "the-unarchiver" # unarchiving most archive files
    "transmission" # torrent client
    "vlc" # video client
    "whatsapp" # whatsapp messaging
    "yellowdot" # hide screen/audio indicator
  ];

  homebrew.masApps = {
    # xcode
    "XCode" = 497799835;
    "Apple Developer" = 640199958;

    # apps
    "DeskRest" = 6751417411; # health
    "Due" = 524373870; # reminders on steroids
    "Keynote" = 409183694; # make slides
    "Klack" = 6446206067; # keyboard
    "NextDNS" = 1464122853; # dns blocking
    "NordVPN" = 905953485;
    "Parcel" = 375589283; # shipment tracking
    "Reeder" = 1529448980; # rss

    # safari extensions
    "1Password for Safari" = 1569813296;
    "Dark Reader for Safari" = 1438243180;
    "DeArrow" = 6451469297;
    "Obsidian Web Clipper" = 6720708363;
    "SponsorBlock" = 1573461917;
    "Vimlike" = 1584519802;
    "uBlock Origin Lite" = 6745342698;
  };
}
