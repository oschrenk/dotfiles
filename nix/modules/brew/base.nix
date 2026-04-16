{ ... }:

# Homebrew packages installed on every machine regardless of role.
{
  homebrew.brews = [
    # bootstrap — required before chezmoi can run
    "age" # cryptography, encryption tool
    "chezmoi" # dotfiles manager
    "git" # git, dvcs
    "git-lfs" # git, large file storage

    # core — essential tools, machine usable without anything else
    "atuin" # cli, improved shell history
    "fd" # system, fast find alternative
    "findutils" # system, GNU g-prefixed find, xargs
    "fzf" # cli, fuzzy finder
    "mas" # cli, Mac App Store interface
    "neovim" # editor
    "oschrenk/made/sessionizer" # tmux, manage sessions
    "ripgrep" # system, recursive search
    "starship" # shell, prompt
    "tmux" # cli, terminal multiplexer

    # core (cli)
    "blueutil" # system, get/set bluetooth from terminal
    "coreutils" # system, GNU core utilities
    "curl" # system, download things
    "gawk" # system, GNU awk utility
    "htop" # system, improved top
    "lsd" # system, "better" ls
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
    "glow" # cli, render markdown in terminal
    "oschrenk/made/plan" # cli, fetch next event
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
    "tweakcc" # ai, claude, customize

    # data
    "jd" # data, diff JSON
    "jq" # data, process JSON (read/transform)
    "jsongrep" # data, process JSON (read only)
    "mdq" # data, process markdown like jq
    "miller" # data, process CSV
    "xq" # data, process xml
    "yq" # data, process YAML

    # database
    "lazysql" # cli, sql
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
    "git-delta" # git, better looking diffs
    "git-extras" # git, nice git extras
    "git-open" # git, open git[hub/lab] urls
    "gh" # cli, interact with github
    "glab" # git, gitlab cli
    "oschrenk/made/arbol" # git, repository manager
    "oschrenk/made/infuse" # git, repository mixer
    "worktrunk" # git, worktree management

    # golang
    "go" # go, language
    "golangci-lint" # go, linter runner
    "gopls" # go, lsp

    # k8s
    "helm" # k8s, package manager
    "k9s" # k8s, cluster manager
    "krew" # k8s, kubectl package manager
    "kube-linter" # k8s, lint k8s yaml and helm
    "kubectx" # k8s, switch k8s contexts
    "kubernetes-cli" # k8s, cli
    "kubescape" # k8s, scan cluster for security issues
    "kustomize" # k8s, resource transformers
    "minikube" # k8s, run local k8s
    "txn2/tap/kubefwd" # k8s, bulk port forwarding

    # kotlin
    "kotlin" # kotlin
    "ktfmt" # kotlin, formatter
    "ktlint" # kotlin, formatter

    # lua
    "lua" # lua, programming language
    "lua-language-server" # lua, lsp
    "luarocks" # lua, package manager
    "stylua" # lua formatter

    # web (javascript, typescript, css, ...)
    "fnm" # javascript, version manager
    "hurl" # network, run/test http requests
    "node" # javascript, language
    "oschrenk/made/cutter" # web, extract cookies
    "oven-sh/bun/bun" # javascript runtime
    "sass/sass/sass" # js, sass
    "typescript" # typescript, language
    "typescript-language-server" # typescript, lsp
    "yarn" # javascript, package manager

    # jvm
    "coursier" # jvm, scala, artifact fetching
    "openjdk@17" # jvm, sdk
    "openjdk@21" # jvm, sdk
    "openjdk" # jvm, sdk
    "oschrenk/personal/scip" # cli, source indexer
    "oschrenk/personal/scip-typescript" # cli, index ts

    # pkl
    "pkl" # pkl, language
    "pkl-lsp" # pkl, lsp

    # python
    "poetry" # python, package manager
    "pyenv" # python, version manager
    "python@3.13" # python, language
    "python@3.14" # python, language
    "uv" # python package manager

    # rust
    "rust" # rust, language

    # scala
    "sbt" # jvm, scala
    "scala" # jvm, scala

    # swift
    "swiftformat" # swift, format
    "swiftlint" # swift, lint, requires Xcode
    "swiftly" # swift, toolchain manager

    # network
    "doggo" # network, dns client
    "httrack" # network, copy websites offline
    "meli" # terminal, email client
    "mosh" # network, better shell for roaming
    "ngrep" # network, packet analyzer
    "nmap" # network, port scanning
    "speedtest-cli" # network, speedtest
    "telnet" # network, telnet protocol

    # docs
    "pandoc" # docs, document converter
    "poppler" # pdf, engine and extractor

    # terraform
    "tfenv" # devops, terraform version manager

    # typst
    "typst" # typst, tex alternative (rust based)

    # a/v + personal
    "asciinema" # a/v, record terminal sessions
    "container" # cli, containerization from Apple
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
