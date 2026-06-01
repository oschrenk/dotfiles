{ ... }:

# Homebrew packages installed on every machine regardless of role.
{
  homebrew.brews = [
    # bootstrap — required before chezmoi can run
    "chezmoi" # dotfiles manager

    # core — essential tools, machine usable without anything else
    "fd" # system, fast find alternative
    "findutils" # system, GNU g-prefixed find, xargs
    "mas" # cli, Mac App Store interface
    "neovim" # editor
    "oschrenk/made/sessionizer" # tmux, manage sessions

    # core (cli)
    "blueutil" # system, get/set bluetooth from terminal
    "coreutils" # system, GNU core utilities
    "curl" # system, download things
    "gawk" # system, GNU awk utility
    "htop" # system, improved top
    "page" # system, use Neovim as pager
    "rclone" # system, sync files
    "rsync" # system, sync files
    "tree" # system, print file tree
    "watch" # system, issue commands at regular interval
    "smartmontools" # hardware, harddrive, read ssd info

    # extra (cli)
    "shellcheck" # shell, linter
    "witr" # cli, why is this running

    # crypto
    "croc" # cryptography, secure data transfer
    "minisign" # cryptography, sign files and verify signatures

    # productivity
    "eddmann/tap/whatsapp-cli" # cli, WhatsApp from terminal
    "glow" # cli, render markdown in terminal
    "oschrenk/made/plan" # cli, fetch next event
    "pandoc" # docs, document converter
    "zola" # web, blogging engine

    # macos
    "keith/formulae/reminders-cli" # cli, reminders
    "keith/formulae/zap" # cli, uninstall macOS apps
    "IohannRabeson/tap/tmignore-rs" # git, ignore files in tmux
    "tag" # terminal, interact with macOS file tags

    # ai
    "llm" # ai, llm on cli
    "ollama" # ai, local models
    "oschrenk/made/meter" # ai, claude, measure usage
    "oschrenk/personal/dora" # ai, navigate code with scip
    "oschrenk/personal/lightpanda" # ai, headless browser
    "rtk" # ai, token proxy

    # data
    "jd" # data, diff JSON
    "jq" # data, process JSON (read/transform)
    "jsongrep" # data, process JSON (read only)
    "mdq" # data, process markdown like jq
    "xq" # data, process xml
    "yq" # data, process YAML

    # database
    "libpq" # postgres, cli
    "pgformatter" # postgres, formatter

    # development
    "prettier" # generic, code formatter
    "prettierd" # generic, code formatter
    "go-task" # generic, go-based task runner
    "yamlfmt" # yaml, formatter

    # editor
    "tree-sitter-cli" # nvim, requirement

    # git
    "git-crypt" # git, encrypt secrets in git
    "gh" # cli, interact with github
    "oschrenk/made/arbol" # git, repository manager
    "oschrenk/made/infuse" # git, repository mixer
    "worktrunk" # git, worktree management

    # container, k8s
    "container" # cli, containerization from Apple
    "k9s" # k8s, cluster manager
    "krew" # k8s, kubectl package manager
    "kube-linter" # k8s, lint k8s yaml and helm
    "kubectx" # k8s, switch k8s contexts
    "kubernetes-cli" # k8s, cli
    "kubescape" # k8s, scan cluster for security issues
    "kustomize" # k8s, resource transformers
    "minikube" # k8s, run local k8s
    "txn2/tap/kubefwd" # k8s, bulk port forwarding

    # lua
    "lua" # lua, programming language
    "lua-language-server" # lua, lsp
    "stylua" # lua formatter

    # web (javascript, typescript, css, ...)
    "hurl" # network, run/test http requests
    "node" # javascript, language
    "oschrenk/made/cutter" # web, extract cookies
    "typescript" # typescript, language
    "typescript-language-server" # typescript, lsp

    # jvm
    "coursier" # jvm, scala, artifact fetching
    "openjdk@17" # jvm, sdk
    "openjdk@21" # jvm, sdk
    "openjdk" # jvm, sdk
    "oschrenk/personal/scip" # cli, source indexer
    "oschrenk/personal/scip-typescript" # cli, index ts

    # python
    "python@3.13" # python, language
    "python@3.14" # python, language
    "uv" # python package manager

    # rust
    "rust" # rust, language

    # swift
    "swiftformat" # swift, format
    "swiftlint" # swift, lint, requires Xcode
    "swiftly" # swift, toolchain manager
    "yapstudios/tap/sfsym" # swift, SF Symbols cli

    # network
    "doggo" # network, dns client
    "httrack" # network, copy websites offline
    "ngrep" # network, packet analyzer
    "nmap" # network, port scanning
    "speedtest-cli" # network, speedtest
    "telnet" # network, telnet protocol


    # a/v + personal
    "asciinema" # a/v, record terminal sessions
    "exiftool" # a/v, read/write exif
    "ffmpeg" # a/v, convert audio/video
    "flac" # a/v, flac codec
    "gallery-dl" # a/v, download gallery
    "lame" # a/v, mp3 codec
    "libmp3splt" # a/v, split mp3, ogg, flac files
    "x264" # a/v, h264 encoder
    "xvid" # a/v, mp4 lib
    "yt-dlp" # a/v, download youtube video/audio
  ];

  homebrew.casks = [
    "1password-cli" # password manager, cli
    "claude-code" # ai, claude
  ];

  homebrew.masApps = {
    "Health Auto Export" = 1115567069; # export apple health data
  };
}
