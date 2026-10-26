# First Run

After Homebrew installs the casks you can already start important apps and configure them

- App Store
  - log into iCloud if needed
- 1Password
  - Security > Touch Id
  - Security > Apple Watch.
  - Developer > Use the SSH Agent
  - Developer > Enable Biometric Unlock
- Ghostty
  - SystemSettings > "Privacy & Security > Full disk access..."
    Allow for ...
- Arc
  - open profiles, and log into services
- Atuin
  - opnix provisions the sync key from 1Password (`Dotfiles` vault), so you need not copy the key between machines.
    Run `atuin login` and enter username + password.
- Karabiner Elements.
  - Open.
    Read "System Extensions Blocked" popup.
    Click on "Open Security Preferences" and press "Allow".
- IntelliJ.
  - Configure plugins.
    - AutoDarkMode
    - Harpooner
    - Hocon
    - Ideavim
    - Key Promoter
    - Kotlin
    - Scala
  - Change settings
    - Don't send statistics
- Photos
  - Open to synchronize data
- Spotify
  - download "Liked Songs"
- sketchybar
  - Managed by Nix Home Manager as a launchd user agent (not brew).
    Restart with `launchctl kickstart -k gui/$(id -u)/org.nix-community.home.sketchybar`

Login:

- Discord
- Slack

Link device:

- Signal
- Telegram
- Whatsapp
