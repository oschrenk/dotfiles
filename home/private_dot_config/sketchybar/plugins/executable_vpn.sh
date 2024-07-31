#!/bin/sh

ICON_COLOR_ACTIVE="0xffcad3f5" 
ICON_COLOR_INACTIVE="0xff484848"

# Supported: 
#   NextDNS
#   NordVPN
# Not Supported:
#   OpenVPN
VPN=$(scutil --nc list | grep Connected | sed -E 's/.*"(.*)".*/\1/')

if [[ $VPN != "" ]]; then
  sketchybar -m --set vpn icon= \
                          icon.color="$ICON_COLOR_ACTIVE" \
                          label="$VPN" 
else
  sketchybar -m --set vpn icon= \
                          icon.color="$ICON_COLOR_INACTIVE" \
                          label="$VPN" 
fi
