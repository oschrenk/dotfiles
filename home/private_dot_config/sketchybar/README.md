# README

## Requirements

sketchybar, [SbarLua](https://github.com/FelixKratz/SbarLua), and `lua-tz` are
provisioned declaratively by nix-darwin + Nix Home Manager via `programs.sketchybar`
in `nix/modules/home/sketchybar.nix`. No manual install needed.

## Debugging

Print

```
# add debug statement
print("debug")
```

Tailing logs

```
# stdout
tail -f ~/Library/Logs/sketchybar/sketchybar.out.log

# stderr
tail -f ~/Library/Logs/sketchybar/sketchybar.err.log
```

## Handling clicks

1. `click_script`

The click_script is only called on a click and can be seen as the core of the click function in the following more general script when the item is subscribed to mouse.clicked:

2. `mouse.clicked` event

Event triggered and available via `$SENDER` variable to distinguish these events in the script.


So, this:

```shell
sketchybar -m --add item tst right \
              --set tst click_script="click_script.sh"
```
does exactly the same as this:

```shell
sketchybar -m --add item tst right \
              --set tst script="script.sh" \
              --subscribe tst mouse.clicked
```
