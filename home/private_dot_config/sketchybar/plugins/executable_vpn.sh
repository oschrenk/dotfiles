#!/bin/sh

# Supported: 
#   NextDNS
#   NordVPN
# Not Supported:
#   OpenVPN
VPN=$(scutil --nc list | grep Connected | sed -E 's/.*"(.*)".*/\1/')

if [[ $VPN != "" ]]; then
  sketchybar -m --set vpn icon= \
                          label="$VPN" 
else
  sketchybar -m --set vpn icon= \
                          label="$VPN" 
fi
