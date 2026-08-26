{ ... }:

# Homebrew packages installed on every machine regardless of role.
{
  homebrew.brews = [

    # core — essential tools, machine usable without anything else
    "fd" # system, fast find alternative
    "findutils" # system, GNU g-prefixed find, xargs
    "mas" # cli, Mac App Store interface
    "neovim" # editor

    # core (cli)
    "coreutils" # system, GNU core utilities
    "curl" # system, download things
    "gawk" # system, GNU awk utility
    "rclone" # system, sync files
    "rsync" # system, sync files
    "watch" # system, issue commands at regular interval

    # crypto
    "croc" # cryptography, secure data transfer

    # productivity
    "eddmann/tap/whatsapp-cli" # cli, WhatsApp from terminal
    "oschrenk/personal/anydoc" # docs, convert documents to markdown
    "pandoc" # docs, document converter

    # macos
    "keith/formulae/reminders-cli" # cli, reminders
    "keith/formulae/zap" # cli, uninstall macOS apps
    "tag" # terminal, interact with macOS file tags

    # ai
    "llm" # ai, llm on cli
    "oschrenk/personal/dora" # ai, navigate code with scip
    "oschrenk/personal/lightpanda" # ai, headless browser
    "oschrenk/made/team" # ai, claude, agent-to-agent messaging bus

    # data
    "jd" # data, diff JSON
    "xq" # data, process xml
    "yq" # data, process YAML

    # database

    # development
    "prettier" # generic, code formatter
    "prettierd" # generic, code formatter
    "go-task" # generic, go-based task runner
    "yamlfmt" # yaml, formatter

    # editor
    "tree-sitter-cli" # nvim, requirement

    # git
    "worktrunk" # git, worktree management

    # container, k8s
    "container" # cli, containerization from Apple

    # lua
    "lua" # lua, programming language
    "lua-language-server" # lua, lsp
    "stylua" # lua formatter

    # web (javascript, typescript, css, ...)
    "node" # javascript, language
    "oschrenk/made/cutter" # web, extract cookies
    "typescript" # typescript, language
    "typescript-language-server" # typescript, lsp

    # jvm
    "coursier" # jvm, scala, artifact fetching
    "openjdk@21" # jvm, sdk
    "openjdk" # jvm, sdk
    "oschrenk/personal/scip" # cli, source indexer
    "oschrenk/personal/scip-typescript" # cli, index ts

    # python
    "python@3.13" # python, language
    "python@3.14" # python, language
    "uv" # python package manager

    # swift
    "yapstudios/tap/sfsym" # swift, SF Symbols cli

    # network
    "httrack" # network, copy websites offline
    "nmap" # network, port scanning
    "telnet" # network, telnet protocol


    # a/v + personal
    "ffmpeg" # a/v, convert audio/video
    "flac" # a/v, flac codec. kept: libmp3splt needs it, and that has no nixpkgs equivalent
    "lame" # a/v, mp3 codec
    "libmp3splt" # a/v, split mp3, ogg, flac files
    "x264" # a/v, h264 encoder
    "xvid" # a/v, mp4 lib
  ];

  homebrew.casks = [
    "claude-code" # ai, claude
  ];

  homebrew.masApps = {
    "Health Auto Export" = 1115567069; # export apple health data
  };
}
