#!/usr/bin/env bash
set -euo pipefail

# Find the UNAS on the local network by its MAC address, and print its IP.
#
# Only earns its keep when the pinned address in nix/options.nix (my.nas.ip) is
# wrong, which is why it identifies the device by MAC rather than by address.
#
# The MAC stays on `op read` rather than moving into secretspec.toml: it lives in
# the Personal vault, which no service account can reach by design, and adding
# that vault to a manifest nix also reads would let a host be wired to secrets it
# can never resolve.

MAC_REF="op://Personal/UNAS 2/MAC"

mac="$(op read "$MAC_REF")"
if [ -z "$mac" ]; then
  echo "Failed to read the MAC address from 1Password." >&2
  exit 1
fi

iface="$(route -n get default 2>/dev/null | awk '/interface:/{print $2}')"
ip="$(ipconfig getifaddr "$iface" 2>/dev/null || true)"
mask="$(ifconfig "$iface" 2>/dev/null | awk '/inet /{print $4}')"

if [ -z "$ip" ] || [ -z "$mask" ]; then
  echo "Could not determine the network interface or its address." >&2
  exit 1
fi

# ifconfig reports the netmask as hex (0xffffff00). Count its set bits to get
# the prefix length nmap wants.
bits=$((16#${mask#0x}))
prefix=0
while [ "$bits" -ne 0 ]; do
  prefix=$((prefix + (bits & 1)))
  bits=$((bits >> 1))
done

subnet="$(echo "$ip" | cut -d. -f1-3).0/$prefix"

# The sweep populates the ARP table; the MAC lookup then reads it.
nmap -sn "$subnet" >/dev/null 2>&1
match="$(arp -a | grep -i "$mac" | head -1 | awk -F'[()]' '{print $2}')"

if [ -n "$match" ]; then
  echo "$match"
else
  echo "UNAS ($mac) not found on $subnet" >&2
  exit 1
fi
