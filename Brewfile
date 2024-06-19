#######################################
# Taps
#######################################
tap "ankitpokhrel/jira-cli"   # jira-cli
tap "coursier/formulas"       # coursier
tap "derailed/k9s"            # k9s
tap "felixkratz/formulae"     # sketchybar
tap "oschrenk/made"           # tools by myself
tap "epk/epk"                 # sf-mono nerd font

# You can list all packages installed via `brew leaves`

#######################################
# Bootstrap priorities
#######################################

# having these installed early in the bootstrapping process allows
# to already configure and use services and applications while brew
# keeps installing other packages

cask "1password"                 # password manager
cask "1password-cli"             # password manager
cask "alacritty"                 # terminal
cask "arc"                       # chromium based browser
cask "karabiner-elements"        # customize keyboard
cask "hammerspoon"               # desktop automation
cask "intellij-idea-ce"          # ide for java/scala
brew "chezmoi"                   # dotfiles manager
brew "fish"                      # shell
brew "starship"                  # prompt
brew "fzf"                       # fuzzy finder
brew "neovim"                    # editor
cask "obsidian"                  # notes
cask "spotify"                # audio client

#######################################
# Packages
#######################################

## system
brew "blueutil"       # get/set bluetooth from terminal
brew "coreutils"      # generic, GNU core utilities
brew "fd"             # generic, fast find alternative
brew "findutils"      # generic, GNU g-prefixed `find`, xargs`
brew "gawk"           # generic, GNU awk utility
brew "oschrenk/made/keyboard" # hardware, control keyboard brightness of macbooks
brew "oschrenk/made/nightshift" # hardware, control Night Shift
brew "oschrenk/made/sessionizer" # tmux, manage sessions
brew "ripgrep"        # generic, recursive search
brew "watch"          # issue commands at regular interval
brew "watchman"       # watch files and take action when they change

## hardware
brew "smartmontools"  # harddrive, read ssd info
brew "m1ddc"          # monitor, control brightness of external monitor

## crypto
brew "age"            # modern and secure encryption too
brew "croc"           # securely transfer data between computers
brew "minisign"       # sign files and verify signatures

## command line
brew "atuin"          # improved shell history
brew "bat"            # "better" cat
brew "chrome-cli"     # control chrome via cli
brew "direnv"         # auto load env
brew "entr"           # run arbitrary commands when files change
brew "gh"             # interact with github
brew "glow"           # render markdown in terminal
brew "htop"           # Improved top
brew "jira-cli"       # interact with jira
brew "lsd"            # "better" ls
brew "page"           # Use Neovim as pager
brew "tree"           # print file tree
brew "tmux"           # terminal multiplexer
brew "walk"           # file manager

# documents
brew "oschrenk/made/noteplan" # noteplan companion
brew "pandoc"                 # document converter
brew "zola"                   # static site generator

# parsing/converting
brew "dos2unix"       # convert text between DOS, UNIX, and Mac formats
brew "jq"             # process JSON
brew "miller"         # process CSV
brew "xmlstarlet"     # process XML
brew "yq"             # process YAML

## network
brew "httrack"        # copy websites offline
brew "hurl"           # run/test http requests
brew "mobile-shell"   # better shell for roaming
brew "ngrep"          # network packet analyzer
brew "nmap"           # port scanning
brew "telnet"         # telnet protocol

## vcs
brew "git"           # dvcs
brew "git-crypt"     # encrypt secrets in git
brew "git-delta"     # better looking diffs
brew "git-extras"    # nice git extras
brew "git-lfs"       # large file storage
brew "git-open"      # open github/gitlab urls from terminal

## a/v
brew "asciinema"     # record terminal sessions
brew "exiftool"      # read/write exif
brew "ffmpeg"        # convert audio/video
brew "flac"          # flac codec
brew "lame"          # mp3 codec
brew "libmp3splt"    # split mp3, off, flac files
brew "mp3splt"       # split mp3, off, flac files
brew "x264"          # h264 encoder
brew "xvid"          # mp4 lib
brew "yt-dlp"        # download youtube video/audio

## programming
brew "cloc"        # generic, count lines of code
brew "coursier/formulas/coursier" # jvm, scala, artifact fetching
brew "fnm"         # javascript, version manger
brew "go"          # go, language
brew "go-task"     # generic, go-based task runner
brew "stylua"      # lua formatter
brew "maven"       # jvm, package manager
brew "node"        # javascript, language
brew "openjdk@11"  # jvm, sdk
brew "openjdk@17"  # jvm, sdk
brew "openjdk@21"  # jvm, sdk
brew "pgcli"       # postgres, just cli
brew "podman"      # generic, manage OCI contaniners and pods
brew "poetry"      # python, package manager
brew "prettier"    # generic, code formatter for js, css, json, md, yaml
brew "pyenv"       # python, version manager
brew "python"      # python, language
brew "rbenv"       # ruby, version manager
brew "ruby-build"  # ruby, version manager
brew "rust"        # rust, language
brew "sbt"         # jvm, scala
brew "shellcheck"  # shell linter
brew "scala"       # jvm, scala
brew "swiftformat" # swift, format
brew "swiftlint"   # swift, lint
brew "tectonic"    # tex
brew "typescript"  # typescript, language
brew "typst"       # tex alternative (rust based)
brew "yamlfmt"     # yaml, formatter
brew "yarn"        # javascript, package manager

# cloud
brew "awscli"  # aws
brew "doctl"   # Digital Ocean
brew "pulumi"  # infrastructure as code
brew "tfenv"   # terraform version manager
brew "traefik" # reverse proxy

# k8s
brew "derailed/k9s/k9s" # k8s, cluster manager
brew "helm"             # k8s, package manager
brew "krew"             # k8s, kubectl package manager
brew "kube-linter"      # k8s, lint k8s yaml and helm
brew "kubectl"          # k8s, cli
brew "kubectx"          # k8s, switch k8s contexts
brew "kustomize"        # k8s, template free k8s resource transformers
brew "minikube"         # k8s, run local k8s
brew "txn2/tap/kubefwd" # k8s, bulk port forwarding

# llm
brew "ollama"           # create, run llm

# macos
brew "dockutil"   # manage the dock
brew "fileicon"   # managing custom icons for files and folders
brew "iconsur"    # download icons from app store
brew "sketchybar" # custom statusbar
brew "8ta4/plist/plist" # watch plist files

# brew "mas"        # app store apps
# waiting for https://github.com/mas-cli/mas/issues/512
brew "nicerloop/nicerloop/mas" # app store apps

#######################################
# Apps
#######################################

mas "Affinity Designer 2", id: 1616831348  # vector editing
mas "Affinity Photo 2", id: 1616822987     # raster editing
mas "Affinity Publisher 2", id: 1606941598 # book publishing
mas "Due", id: 524373870                   # reminders on steroid
mas "Health Auto Export", id: 1115567069   # export apple health data
mas "HomeControl", id: 1547121417          # apple home
mas "Keynote", id: 409183694               # make slides
mas "NextDNS", id: 1464122853              # dns blocking
mas "NordVPN", id: 905953485               # NordVPN
mas "Numbers", id: 409203825               # excel
mas "Pages", id: 409201541                 # docs
mas "Reeder 5", id: 1529448980             # rss
# mas "XCode", id: 497799835  # see eof, because of size last thing to install

#######################################
# Fonts
#######################################

cask "font-fira-code"
cask "font-ia-writer-duo"
cask "font-ia-writer-quattro"
cask "font-iosevka"
cask "font-jetbrains-mono-nerd-font"
cask "font-m-plus-code-latin"
cask "font-mplus-nerd-font"
cask "font-open-sans"
cask "font-roboto-mono"
cask "font-roboto-mono-nerd-font"
cask "font-sf-mono-nerd-font"
cask "font-victor-mono"

#######################################
# Casks
#######################################

cask "android-platform-tools" # android sdk
cask "bruno"                  # test APIs
cask "calibre"                # ebook manager
cask "google-chrome"          # browser
cask "cog"                    # audio client
cask "dbeaver-community"      # sql client
cask "db-browser-for-sqlite"  # sqlite client
cask "diffusionbee"           # Stable Diffusion locally
cask "discord"                # discord client
cask "docker"                 # docker client
cask "elgato-control-center"  # elgato software to control lights
cask "firefox"                # browser
cask "flux"                   # control screen color temperature
cask "grammarly-desktop"      # grammarly client
cask "handbrake"              # video transcoder
cask "hiddenbar"              # hide menu bar items
cask "hex-fiend"              # hex editor
cask "iina"                   # video client
cask "jdk-mission-control"    # monitor java applications
cask "keyboardcleantool"      # disables keyboard for cleaning
cask "keycastr"               # shows key strokes on screen
cask "knockknock"             # identify background tasks/processes
cask "mindmac"                # llm api client
cask "mochi"                  # study notes and flashcards
cask "monodraw"               # draw ascii art
cask "musicbrainz-picard"     # audio collection organizer
cask "neovide"                # neovim desktop app
cask "numi"                   # calculator
cask "obs"                    # broadcasting
cask "ollamac"                # gui for ollama
cask "onyx"                   # macos maintenance
cask "omnidisksweeper"        # cleanup disk space
cask "podman-desktop"         # generic, manage containers and pods
cask "postman"                # api development
cask "raindropio"             # bookmark managment
cask "rocket"                 # quick emoji access
cask "rode-central"           # rode companion app (for AI-1)
cask "signal"                 # signal messaging
cask "slack"                  # slack office communication
cask "steam"                  # gaming client
cask "telegram"               # telegram messaging
cask "the-unarchiver"         # unarchiving  most archive files
cask "topnotch"               # "hide" notch
cask "transmission"           # torrent client
cask "visual-studio-code"     # editor
cask "vlc"                    # video client
cask "whisky"                 # wine client
cask "whatsapp"               # whatsapp messaging
cask "xld"                    # cd ripper
cask "zed"                    # editor
cask "zoom"                   # video conferencing

#######################################
# Xcode
#######################################

brew "xcodes"      # xcode & runtimes manager
mas "XCode", id: 497799835
mas "Apple Developer", id: 640199958
# to agree to license
# sudo xcodebuild -license
