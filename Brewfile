#######################################
# Taps
#######################################
tap "coursier/formulas"       # coursier
tap "derailed/k9s"            # k9s
tap "homebrew/cask-drivers"   # elgato control center, rode-central
tap "homebrew/cask-fonts"     # fonts
tap "oschrenk/casks"          # mplus-mn-nerd-font-complete-mono
tap "txn2/tap"                # kubefwd

# You can list all packages installed via
# brew "leaves"

#######################################
# Bootstrap priorities
#######################################

# having these installed early in the bootstrapping process allows
# to already configure and use services and applications while brew
# keeps installing other packages

cask "1password"
cask "1password-cli"
cask "alacritty"
cask "google-chrome"
cask "karabiner-elements"
cask "hammerspoon"
cask "intellij-idea-ce"
brew "chezmoi"
brew "fish"
brew "fzf"
mas "Bear", id: 1091189122
mas "NotePlan 3", id: 1505432629

#######################################
# Packages
#######################################

## system
brew "blueutil"       # get/set bluetooth from terminal
brew "coreutils"      # GNU core utilities
brew "findutils"      # g-prefixed `find`, `locate`, `updatedb`,`xargs`
brew "gawk"           # GNU awk utility
brew "the_silver_searcher" # Code-search similar to ack
brew "watch"          # issue commands at regular interval
brew "watchman"       # watch files and take action when they change

## edit
brew "ctags"          # generate index of symbols
brew "neovim"
brew "vim"

## crypto
brew "age"            # modern and secure encryption too
brew "magic-wormhole" # Securely transfers data between computers
brew "croc"           # Securely transfers data between computers

## command line
brew "bat"            # "better" cat
brew "chrome-cli"     # control chrome via cli
brew "direnv"         # auto load env
brew "exa"            # "better" ls
brew "fzf"            # fuzzy file finder
brew "htop"           # Improved top
brew "pandoc"         # document converter,
brew "tmux"           # terminal multiplexer
brew "tmuxp"          # tmux session manager

# parsing/converting
brew "dos2unix"       # convert text between DOS, UNIX, and Mac formats
brew "jq"             # process JSON
brew "miller"         # process CSV
brew "xmlstarlet"     # process XML
brew "yq"             # process YAML

## network
brew "httrack"
brew "nmap"
brew "ngrep"
brew "mobile-shell"
brew "ssh-copy-id"
brew "telnet"

## http
brew "curl"
brew "wget"

## vcs
brew "diff-so-fancy"        # better looking diffs
brew "git"                  # dvcs
brew "git-crypt"            # encrypt secrets in git
brew "git-extras"           # nice git extras
brew "git-lfs"              # large file storage
brew "git-open"             # open github/gitlab urls from terminal
brew "svn"                  # svn,some packages eg roboto font rely on it

# cli
brew "chezmoi"
brew "gh"                  # interact with github
brew "go-jira"

## a/v
brew "asciinema"
brew "exiftool"
brew "ffmpeg"
brew "flac"
brew "imagemagick@6"
brew "lame"
brew "libmp3splt"
brew "mp3splt"
brew "sox"
brew "x264"
brew "xvid"
brew "yt-dlp"

## programming
brew "bower"       # JavaScript Package Manager
brew "coursier/formulas/coursier" # Pure Scala Artifact Fetching
brew "cloc"        # count lines of code
brew "cmake"       # cross-platform  build automation
brew "podman"      # manage OCI contaniners and pods
cask "podman-desktop" # manage OCI contaniners and pods
brew "fnm"         # node version manger
brew "go"          # go
brew "grunt-cli"   # JavaScript Task Runner
brew "maven"       # jvm
brew "node"        # javascript
brew "openjdk@8"   # jvm
brew "openjdk@11"  # jvm
brew "openjdk@17"  # jvm
brew "python"      # python
brew "poetry"      # python
brew "rbenv"       # ruby
brew "ruby-build"  # ruby
brew "rust"        # rust
brew "sbt"         # scala
brew "scala"       # scala
brew "tectonic"    # tex
brew "typescript"  # typescript
brew "yarn"        # javascript

# cloud
brew "awscli"             # aws
brew "derailed/k9s/k9s"
brew "doctl"              # Digital Ocean
brew "helm"
brew "kubectl"
brew "kubectx"
brew "kustomize"
brew "krew"               # Package manager for kubectl plugins
brew "kube-linter"
brew "minikube"
brew "pulumi"
brew "tfenv"
brew "traefik"
brew "txn2/tap/kubefwd"

# macos
brew "fileicon"   # managing custom icons for files and folders
brew "mas"        # app store apps

#######################################
# Apps
#######################################

mas "Affinity Designer 2", id: 1616831348
mas "Affinity Photo 2", id: 1616822987
mas "Affinity Publisher 2", id: 1606941598
mas "Apple Configurator", id: 1037126344
mas "Controller", id: 1198176727
mas "Day One", id: 1055511498
mas "Due", id: 524373870
mas "Health Auto Export", id: 1115567069
mas "HomeControl", id: 1547121417
mas "iMovie", id: 408981434
mas "Keynote", id: 409183694
mas "MindNode", id: 1289197285
mas "NextDNS", id: 1464122853
mas "NordVPN", id: 905953485
mas "Numbers", id: 409203825
mas "Pages", id: 409201541
mas "PhotoScape X", id: 929507092
mas "Reeder 5", id: 1529448980
mas "Session", id: 1521432881
mas "stoic.", id: 1312926037
mas "Tip", id: 1495732622
mas "VOX", id: 461369673
# mas "XCode", id: 497799835  # see eof, because of size last thing to install

#######################################
# Fonts
#######################################

cask "font-fira-code"
cask "font-ia-writer-duo"
cask "font-ia-writer-quattro"
cask "font-iosevka"
cask "font-mplus"
cask "font-open-sans"
cask "font-open-sans-condensed"
cask "font-roboto-mono"
cask "font-roboto-mono-nerd-font"
cask "font-victor-mono"
cask "mplus-mn-nerd-font-complete-mono"

#######################################
# Casks
#######################################

cask "android-platform-tools"
cask "arc"
cask "calibre"
cask "cog"
cask "dbeaver-community"
cask "discord"
cask "docker"
# until https://github.com/kcrawford/dockutil/issues/127 is resolved
# install dockutil via this cask
cask "hpedrorodrigues/tools/dockutil"
cask "elgato-control-center"
cask "firefox"
cask "flux"
cask "grammarly-desktop"
cask "handbrake"
cask "hex-fiend"
cask "insomnia"
cask "iina"
cask "jdk-mission-control"
cask "jdownloader"
cask "keyboardcleantool"
cask "keycastr"             # shows key strokes on screen
cask "knockknock"
# Lens 5.5 required login, use OpenLens
# cask "lens"
cask "ykursadkaya/openlens/openlens"
cask "meld"
cask "microsoft-azure-storage-explorer"
cask "monodraw"
cask "numi"
cask "obs"
cask "omnidisksweeper"
cask "omnigraffle"
cask "paparazzi"
cask "plan"
cask "postman"
cask "rocket"               # quick emoji access
cask "rode-central"
cask "sequel-pro"
cask "signal"
cask "slack"
cask "spotify"
cask "steam"
cask "telegram"
cask "the-unarchiver"
cask "transmission"
cask "visual-studio-code"
cask "vlc"
cask "zoom"

#######################################
# Xcode
#######################################

mas "XCode", id: 497799835
# to agree to license
# sudo xcodebuild -license
