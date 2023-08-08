#######################################
# Taps
#######################################
tap "ankitpokhrel/jira-cli"   # jira-cli
tap "arl/arl"                 # gitmux
tap "coursier/formulas"       # coursier
tap "derailed/k9s"            # k9s
tap "homebrew/cask-drivers"   # elgato control center, rode-central
tap "homebrew/cask-fonts"     # fonts
tap "txn2/tap"                # kubefwd

# You can list all packages installed via
# brew "leaves"

#######################################
# Bootstrap priorities
#######################################

# having these installed early in the bootstrapping process allows
# to already configure and use services and applications while brew
# keeps installing other packages

cask "1password"                 # password manager
cask "1password-cli"             # password manager
cask "alacritty"                 # terminal
cask "google-chrome"             # browser
cask "karabiner-elements"        # customize keyboard
cask "hammerspoon"               # desktop automation
cask "intellij-idea-ce"          # ide for java/scala
brew "chezmoi"                   # dotfiles manager
brew "fish"                      # shell
brew "fzf"                       # fuzzy finder
mas "Bear", id: 1091189122       # notes
mas "NotePlan 3", id: 1505432629 # daily notes

#######################################
# Packages
#######################################

## system
brew "blueutil"       # get/set bluetooth from terminal
brew "coreutils"      # GNU core utilities
brew "fd"             # fast find alternative
brew "findutils"      # g-prefixed `find`, `locate`, `updatedb`,`xargs`
brew "gawk"           # GNU awk utility
brew "ripgrep"        # Code-search like grep and the_silver_searcher
brew "the_silver_searcher" # Code-search similar to ack
brew "watch"          # issue commands at regular interval
brew "watchman"       # watch files and take action when they change

## edit
brew "ctags"          # generate index of symbols
brew "neovim"         # editor

## crypto
brew "age"            # modern and secure encryption too
brew "croc"           # Securely transfers data between computers

## command line
brew "bat"            # "better" cat
brew "chrome-cli"     # control chrome via cli
brew "direnv"         # auto load env
brew "entr"           # run arbitrary commands when files change
brew "exa"            # "better" ls
brew "fzf"            # fuzzy file finder
brew "gh"             # interact with github
brew "gitmux"         # git status in tmux status bar
brew "htop"           # Improved top
brew "jira-cli"       # interact with jira
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
brew "httrack"        # copy websites offline
brew "nmap"           # port scanning
brew "ngrep"          # network packet analyzer
brew "mobile-shell"   # better shell for roaming
# brew "ssh-copy-id" # included/managed by macos

brew "telnet"         # telnet protocol

## http
# brew "curl"  # included/managed by macos

## vcs
brew "git"                  # dvcs
brew "git-crypt"            # encrypt secrets in git
brew "git-delta"            # better looking diffs
brew "git-extras"           # nice git extras
brew "git-lfs"              # large file storage
brew "git-open"             # open github/gitlab urls from terminal
brew "svn"                  # svn,some packages eg roboto font rely on it


## a/v
brew "asciinema"     # record terminal sessions
brew "exiftool"      # read/write exif
brew "ffmpeg"        # convert audio/video
brew "flac"          # flac codec
# brew "imagemagick@6" # included/managed by macos
brew "lame"          # mp3 codec
brew "libmp3splt"    # split mp3, off, flac files
brew "mp3splt"       # split mp3, off, flac files
brew "sox"           # edit audio
brew "x264"          # h264 encoder
brew "xvid"          # mp4 lib
brew "yt-dlp"        # download youtube video/audio

## programming
brew "bower"       # JavaScript Package Manager
brew "coursier/formulas/coursier" # Pure Scala Artifact Fetching
brew "cloc"        # count lines of code
brew "cmake"       # cross-platform  build automation
brew "podman"      # manage OCI contaniners and pods
cask "podman-desktop" # manage OCI contaniners and pods
brew "fnm"         # node version manger
brew "go"          # go
brew "go-task"     # go-based task runner as Make replacement
brew "grunt-cli"   # JavaScript Task Runner
brew "maven"       # jvm
brew "node"        # javascript
brew "openjdk@11"  # jvm
brew "openjdk@17"  # jvm
brew "python"      # python
brew "poetry"      # python
brew "pyenv"       # python
brew "rbenv"       # ruby
brew "ruby-build"  # ruby
brew "rust"        # rust
brew "sbt"         # scala
brew "scala"       # scala
brew "tectonic"    # tex
brew "typescript"  # typescript
brew "yarn"        # javascript

# cloud
brew "awscli"  # aws
brew "doctl"   # Digital Ocean
brew "pulumi"  # infrastructure as code
brew "tfenv"   # terraform version manager
brew "traefik" # reverse proxy

# k8s
brew "derailed/k9s/k9s"
brew "helm"             # k8s package manager
brew "kubectl"          # k8s cli
brew "kubectx"          # switch k8s contexts
brew "kustomize"        # template free k8s resource transformers
brew "krew"             # package manager for kubectl plugins
brew "kube-linter"      # lint k8s yaml and helm
brew "minikube"         # run local k8s
brew "txn2/tap/kubefwd" # bulk port forwarding

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
cask "font-mplus-nerd-font"
cask "font-open-sans"
cask "font-open-sans-condensed"
cask "font-roboto-mono"
cask "font-roboto-mono-nerd-font"
cask "font-victor-mono"

#######################################
# Casks
#######################################

cask "android-platform-tools" # android sdk
cask "arc"                  # chromium based browser
cask "calibre"              # ebook manager
cask "cog"                  # audio client
cask "dbeaver-community"    # sql client
cask "discord"              # discord client
cask "docker"               # docker client
# until https://github.com/kcrawford/dockutil/issues/127 is resolved
# install dockutil via this cask
cask "hpedrorodrigues/tools/dockutil"
cask "elgato-control-center" # elgato software to control lights
cask "firefox"              # browser
cask "flux"                 # control screen color temperature
cask "grammarly-desktop"    # grammarly client
cask "handbrake"            # video transcoder
cask "hex-fiend"            # hex editor
cask "insomnia"             # http and graphql client
cask "iina"                 # video client
cask "jdk-mission-control"  # monitor java applications
cask "keyboardcleantool"    # disables keyboard for easier cleaning
cask "keycastr"             # shows key strokes on screen
cask "knockknock"           # identify macos background tasks/processes
# Lens 5.5 required login, use OpenLens
# cask "lens"
# cask "ykursadkaya/openlens/openlens"
cask "meld"                 # 3 way merge tool
cask "microsoft-azure-storage-explorer"
cask "monitorcontrol"       # control brightness for external monitor
cask "monodraw"             # draw ascii art
cask "numi"                 # calculator
cask "obs"                  # broadcasting
cask "omnidisksweeper"      # cleanup disk space
cask "paparazzi"            # make screenshots of websites
cask "postman"              # api development
cask "rocket"               # quick emoji access
cask "rode-central"         # rode companion app (for AI-1)
cask "sequel-pro"           # sql client
cask "signal"               # signal messaging
cask "slack"                # slack office communication
cask "spotify"              # audio client
cask "steam"                # gaming client
cask "telegram"             # telegram messaging
cask "the-unarchiver"       # unarchiving for most archive files
cask "topnotch"             # "hide" notch
cask "transmission"         # torrent client
cask "visual-studio-code"   # editor
cask "vlc"                  # video client
cask "whatsapp"             # whatsapp messaging
cask "zoom"                 # video conferencing

#######################################
# Xcode
#######################################

mas "XCode", id: 497799835
# to agree to license
# sudo xcodebuild -license
