# Homelab Architecture

## Physical layout

How devices are connected at the network hardware level.

```mermaid
graph TD
    ISP["Claro<br/>Fiber"]

    subgraph "Home LAN"
        Huawei["Huawei EchoLife EG8245W5-6T<br/>Router / DHCP"]
        Switch["Ubiquiti Flex Mini<br/>5-port 2.5GbE"]
        Netgear["Netgear GS305P<br/>5-port GbE PoE+ 63W"]
        Laptop["olivers-maxbook<br/>macOS"]
        unas["unas<br/>NAS"]
        pi1["pi-1 (PoE)<br/>RPi 4B 4GB<br/>192.168.1.7<br/>AdGuard DNS"]
        pi2["pi-2 (PoE)<br/>RPi 4B 4GB<br/>Unifi Controller"]
        pi3["pi-3 (PoE)<br/>RPi 4B 4GB<br/>idle"]
    end

    ISP --> Huawei
    Huawei --> Switch
    Switch --> Laptop
    Switch --> unas
    Switch --> Netgear
    Netgear --> pi1
    Netgear --> pi2
    Netgear --> pi3
```

## Tailscale overlay

All devices are members of the `your-tailnet.ts.net` tailnet and can reach each other directly over WireGuard.

- Client devices
  - `olivers-maxbook` (macOS)
  - `iphone-13-mini` (iOS)
  - `ipad` (iOS)
- `tag:bramble`
  - `pi-1` (NixOS)
  - `pi-2` (NixOS)
  - `pi-3` (NixOS)
  - `unas` (NixOS)

## DNS and HTTPS

Local domain: `home.lan`. This is a private domain that does not exist on the public internet - it only resolves because AdGuard on `pi-1` handles DNS and rewrites `*.home.lan` names locally. Without a custom DNS resolver, no client would be able to find these services.

**On LAN:** the Huawei router does not support custom DNS via DHCP. As a workaround, `pi-1`'s LAN IP is hardcoded as the DNS resolver in `olivers-maxbook`'s network settings. A query for `*.home.lan` returns `pi-1`'s LAN IP.

**Over Tailscale:** not yet configured. To make `home.lan` resolve remotely, Tailscale needs a custom DNS resolver pointing to AdGuard on `pi-1`'s Tailscale IP.

In both cases traffic terminates at Traefik on `pi-1`, which routes to the correct service by `Host` header. Clients must import the self-signed cert to trust the HTTPS connection.
