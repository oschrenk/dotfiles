#!/bin/sh

# requires https://github.com/oschrenk/keyboard.swift
echo "Keyboard: Set brightness lowest, automatic and turn off after 10s"
/opt/homebrew/bin/keyboard set --auto-brightness=true --idle-dim-time=10 --brightness=0.01
