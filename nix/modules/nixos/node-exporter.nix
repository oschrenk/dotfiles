{ ... }:
# node_exporter, systemd collector only. Prometheus on pi-2 scrapes it over
# the tailnet, and gatus alerts by querying prometheus, so this is both the
# graph source and the alert source for dead units.
#
# The default collectors stay off: kula already exports cpu, memory and
# temperature, and a second copy would just double the series.
#
# Coverage is exclude-based on purpose. The include rule is only the unit
# type, so every service and mount — present or added later — is watched
# unless an exclude drops it. The excludes name stable OS plumbing prefixes,
# nothing this homelab runs.
{
  services.prometheus.exporters.node = {
    enable = true;
    # Listens on all interfaces: the firewall keeps the LAN out and tailscale0
    # is trusted, same as kula. 9102 because json-exporter sits near 9100's
    # neighborhood on pi-2 and an explicit value keeps the scrape config honest.
    port = 9102;
    # Via enabledCollectors, not a raw flag: the NixOS module only opens its
    # sandbox for the dbus socket (AF_UNIX) when it sees the collector here.
    enabledCollectors = [ "systemd" ];
    extraFlags = [
      "--collector.disable-defaults"
      # [.] instead of \. — systemd strips unknown escapes from ExecStart.
      "--collector.systemd.unit-include=.+[.](service|mount)"
      # Two families of noise: systemd's own helpers and per-boot oneshots
      # (first alternation), and the kernel API mounts (second). Real mounts
      # like /, /home, /boot/firmware, /nix/store and the NAS survive.
      "--collector.systemd.unit-exclude=^(systemd-|getty@|serial-getty@|console-getty|user@|user-runtime-dir@|modprobe@|dbus|polkit|nscd|logrotate|kmod|audit|mount-pstore|reload-systemd-vconsole|save-hwclock|emergency|rescue|initrd-|plymouth-|prepare-kexec|generate-shutdown-ramfs|lastlog2-import|linger-users|sshd-keygen|suid-sgid-wrappers|syslog|cpufreq|fstrim|post-boot|dev-|sys-|run-|proc-).*"
    ];
  };
}
