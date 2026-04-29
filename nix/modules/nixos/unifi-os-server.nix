{ config, pkgs, ... }:

# Run UniFi OS Server on pi-2 as a declarative OCI container.
#
# We extract the official Ubiquiti container image from their installer binary
# (with binwalk), then run it via virtualisation.oci-containers. This avoids
# the installer entirely; on NixOS the installer hits a structural wall at
# /etc/systemd/system/ being read-only (it resolves into /nix/store).
#
# See plans/unifi-os.md and https://discourse.nixos.org/t/unifi-os-server-on-nixos/76039
#
# Operations & liveness checks:
#
# Layer 1 - is the host's systemd unit running?
#   sudo systemctl status podman-unifi-os-server
#       Should show "active (running)". `activating (start-pre)` means the
#       container is loading the image (slow on first boot, ~10 min).
#
# Layer 2 - is the podman container alive?
#   sudo podman ps
#       Confirms the container is up, with port mappings. `STATUS: Up Xs`.
#
# Layer 3 - are the inner services healthy?
#   sudo podman exec unifi-os-server systemctl --failed --no-pager
#       Should print "0 loaded units listed." Anything failed (mongodb most
#       commonly) blocks the controller from finishing boot.
#   sudo podman exec unifi-os-server systemctl list-units --state=activating --no-pager
#       Shows what's still warming up. Empty = fully booted. `unifi.service`
#       in `activating start` means the JVM is still initialising (2-3 min).
#
# Layer 4 - is the controller actually serving?
#   curl -k -s -o /dev/null -w "%{http_code}\n" https://localhost/
#       Run on pi-2. 200 = serving. 503 / connection refused = not yet.
#   sudo podman exec unifi-os-server tail -f /var/log/unifi/server.log
#       The controller's own log. Look for "Application Started" or recent
#       activity (no exceptions every 8s = healthy). Other files of interest
#       in /var/log/unifi: startup.log, migration.log, tasks.log.
#
# Layer 5 - end-to-end (browser): https://pi-2.local/
#       Should land on the first-run setup wizard or the login page if
#       already configured. "UniFi OS Server Booting" indefinitely = stuck;
#       fall back to layer 4 to see why.
#
# Common failure shortcuts:
#   "Invalid UUID string" loop → /var/lib/uos-server/data/uos_uuid is empty;
#       remove and restart so the entrypoint re-seeds from UOS_UUID env.
#   mongodb in --failed list → the mongoPreStartFix drop-in didn't apply or
#       the data dir perms are wrong; see comment by `mongoPreStartFix`.
#   beam.smp / RabbitMQ exiting → bump --pids-limit further.
#
# First-boot timing on a Pi 4:
#   - podman load (one-time, after fresh rmi or first deploy): ~10 min
#     for the 1.99 GB image; subsequent restarts are seconds because the
#     layers are already in podman's storage.
#   - mongo init (one-time, fills /var/lib/uos-server/mongodb): ~30 s.
#   - controller startup (every restart): 2-3 min for the JVM, schema
#     migrations, and the loading page to advance to the setup wizard.
#   The browser shows "UniFi OS Server Booting / 1-2 minutes" while waiting.
let
  version = "5.0.6";

  # Fetch + binwalk-extract the OCI image embedded in Ubiquiti's installer.
  # On first build, leave hash = lib.fakeHash; nix will print the real hash in
  # the build error, paste it back here.
  unifiOsImage = pkgs.stdenv.mkDerivation {
    pname = "unifi-os-server-image";
    inherit version;
    src = pkgs.fetchurl {
      url = "https://fw-download.ubnt.com/data/unifi-os-server/df5b-linux-arm64-${version}-f35e944c-f4b6-4190-93a8-be61b96c58f4.6-arm64";
      hash = "sha256-aKCig6g1tSj+QHkarf1czVGOBRkHVmkjdX9sWy/rzQg=";
    };
    nativeBuildInputs = [ pkgs.binwalk ];
    # The installer is a raw binary, not an archive — skip the default unpack
    # phase so stdenv doesn't try (and fail) to extract it.
    dontUnpack = true;
    installPhase = ''
      mkdir -p $out
      binwalk -e $src -C $TMPDIR
      # binwalk's output directory naming varies by version; locate image.tar
      # wherever it landed.
      image_tar=$(find $TMPDIR -name image.tar -print -quit)
      if [ -z "$image_tar" ]; then
        echo "image.tar not found after binwalk extraction" >&2
        find $TMPDIR -maxdepth 3 >&2
        exit 1
      fi
      tar -xf "$image_tar" -C $out
    '';
  };

  # Ubiquiti's image ships with empty RepoTags AND a hybrid Docker/OCI
  # manifest format. Podman's `load` accepts the layers but silently drops
  # the RepoTags array, leaving the image as <none>:<none> and unaddressable
  # by name. We reference it by its content-addressed digest instead.
  #
  # Hardcoded (instead of computed via IFD from `${unifiOsImage}/manifest.json`)
  # to avoid forcing the Mac to fetch the entire 1.99 GB image just to read
  # a few bytes during evaluation. Bump alongside `version` and `hash`: get
  # the new value from `podman image ls` after a successful first deploy
  # (the long sha256 of the IMAGE ID column).
  imageDigest = "sha256:bc2d80c47b7fe79e2f0addbf47ca4a28c65a56321220d249d320a80c3bdb44da";

  stateDir = "/var/lib/uos-server";

  # systemd drop-in mounted into the container at
  # /etc/systemd/system/mongodb.service.d/00-prestart.conf to add an
  # ExecStartPre that creates /var/log/mongodb and chowns the dirs mongo needs.
  # The container's stock mongodb.service has no such step (Ubiquiti's installer
  # normally runs it during host setup). Without this, mongod exits 100
  # silently because it can't open its log file. Fix from the discourse thread.
  mongoPreStartFix = pkgs.writeText "mongo-prestart.conf" ''
    [Service]
    ExecStartPre=+/bin/bash -c "mkdir -p /var/log/mongodb && chown mongodb:mongodb /var/log/mongodb /var/lib/mongodb"
  '';

in
{
  # Container runtime. Rootful is intentional: the controller binds privileged
  # ports (443) and integrates more cleanly with system-level systemd via
  # virtualisation.oci-containers.
  virtualisation.podman.enable = true;
  virtualisation.oci-containers.backend = "podman";

  virtualisation.oci-containers.containers.unifi-os-server = {
    # Reference by content-addressed digest, not a name:tag, because Ubiquiti's
    # image loads as <none>:<none> (see imageDigest definition above for why).
    # The digest is what podman actually identifies the image by internally.
    image = imageDigest;
    imageFile = unifiOsImage;
    pull = "never";

    # Web UI plus the device-talk ports a controller normally needs.
    # 443/tcp     - UniFi OS Server web UI
    # 8080/tcp    - device inform (UAPs/USWs talk to the controller here)
    # 8443/tcp    - legacy controller HTTPS (kept for adoption compat)
    # 8843/tcp    - guest portal HTTPS
    # 8880/tcp    - guest portal HTTP
    # 6789/tcp    - mobile speed test
    # 3478/udp    - STUN
    # 10001/udp   - AP discovery
    ports = [
      "443:443"
      "8080:8080"
      "8443:8443"
      "8843:8843"
      "8880:8880"
      "6789:6789"
      "3478:3478/udp"
      "10001:10001/udp"
    ];

    # Persist all state outside the container so rebuilds don't lose data.
    volumes = [
      "${stateDir}/persistent:/persistent"
      "${stateDir}/data:/data"
      "${stateDir}/unifi:/var/lib/unifi"
      "${stateDir}/mongodb:/var/lib/mongodb"
      "${stateDir}/srv:/srv"
      # Drop-in to fix mongo's missing prestart (see definition above).
      "${mongoPreStartFix}:/etc/systemd/system/mongodb.service.d/00-prestart.conf:ro"
    ];

    environment = {
      # IP that APs and other UniFi devices will use to reach the controller.
      # Must be pi-2's LAN address, not localhost — otherwise adopted devices
      # see "controller at 127.0.0.1" and can't connect.
      UOS_SYSTEM_IP = config.my.host."pi-2".lanIp;
      UOS_SERVER_VERSION = version;
      FIRMWARE_PLATFORM = "linux-arm64";
      # The container's entrypoint writes this to /data/uos_uuid on first
      # boot, but only if that file doesn't already exist. If a previous
      # run wrote an empty/bad value, you must `rm /var/lib/uos-server/data/uos_uuid`
      # on the host before restarting for the new value to take effect.
      # UUID is the deterministic one Ubiquiti's installer generated for
      # pi-2 the first time we ran it (derived from /etc/machine-id).
      # Entrypoint logic: https://github.com/lemker/unifi-os-server/blob/main/uos-entrypoint.sh
      UOS_UUID = "74af3841-5ebf-5870-8ced-e6bb8325c24d";
    };

    extraOptions = [
      # The container runs systemd internally; tell podman to honour that.
      "--systemd=always"
      # Lets services inside the container reach the host (used for some
      # discovery flows).
      "--add-host=host.docker.internal:host-gateway"
      # RabbitMQ's beam.smp creates hundreds of scheduler/helper threads;
      # podman's default --pids-limit=2048 is too tight and beam.smp crashes
      # with EAGAIN. 8192 is the discourse-thread-recommended bump.
      "--pids-limit=8192"
    ];
  };

  # Create the state directory tree at activation time. systemd-tmpfiles is the
  # NixOS-canonical way to declare directories that need to exist at boot.
  # Ownership inside the container (e.g. mongodb's data dir to mongodb:mongodb)
  # is handled by the mongoPreStartFix drop-in, so we just need the dirs to
  # exist on the host.
  systemd.tmpfiles.rules = [
    "d ${stateDir} 0755 root root -"
    "d ${stateDir}/persistent 0755 root root -"
    "d ${stateDir}/data 0755 root root -"
    "d ${stateDir}/unifi 0755 root root -"
    "d ${stateDir}/mongodb 0755 root root -"
    "d ${stateDir}/srv 0755 root root -"
  ];

  networking.firewall.allowedTCPPorts = [
    443
    8080
    8443
    8843
    8880
    6789
  ];
  networking.firewall.allowedUDPPorts = [
    3478
    10001
  ];
}
