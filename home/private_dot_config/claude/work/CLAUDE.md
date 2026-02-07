# Clipboard

To copy text to the clipboard, pipe data to the platform-specific command:

- macOS: `echo "text" | pbcopy`
- Linux: `echo "text" | xclip -selection clipboard`
- Windows: `echo "text" | clip`
- WSL2: `echo "text" | clip.exe`
