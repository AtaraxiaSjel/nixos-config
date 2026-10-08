# tachyon — incus (target state: base + SSH + incus).
# Iteration 1: daemon only, no preseed/networks/UI/secrets.
# Purpose: price incus in isolation via diff-closures against the baseline.
{ pkgs, ... }:
{
  # Router policy: modern stack only (nftables, networkd), no legacy
  # scripted networking. nftables backend is also a hard requirement of
  # the stock incus module (it refuses to evaluate on iptables).
  networking.nftables.enable = true;

  virtualisation.incus = {
    enable = true;
    # Web UI priced at +20 MiB (single self-contained path), worth it.
    ui.enable = true;
    # Shrink the daemon package WITHOUT recompiling Go (a full emulated
    # rebuild takes ~30 min and OOMs: 16 parallel qemu-user go-compiles).
    # Plain copy minus files: static Go binaries carry no intra-package
    # refs, so a copy is closure-safe. Plain `rm` (no -f) on purpose: if
    # upstream renames a binary the build fails loudly instead of silently
    # rotting the list. Dropped: one-shot/dev CLIs the daemon never execs
    # and the module never references (it uses only incusd/incus/incus-user
    # — verified by grep). Keep list: incusd, incus CLI (used by the owner
    # too, incl. `admin shutdown/init`), incus-user, fuidshift (exec'd by
    # the daemon for id shifting), tls2jwt, dev_incus-client. share/agent
    # stays (guest agent, cheap insurance).
    package =
      (pkgs.runCommand "${pkgs.incus-lts.name}-slim" { } ''
        cp -r ${pkgs.incus-lts} $out
        chmod -R u+w $out
        rm $out/bin/incus-migrate $out/bin/incus-simplestreams \
          $out/bin/lxc-to-incus $out/bin/lxd-to-incus \
          $out/bin/incus-benchmark $out/bin/generate-database
      '').overrideAttrs
        (
          _final: _prev: {
            # Re-attach upstream passthru: the module defaults clientPackage to
            # `config.virtualisation.incus.package.client` (standalone 25 MB CLI
            # for PATH — already minimal, also kept for the owner).
            passthru = {
              client = pkgs.incus-lts.client;
            };
          }
        );
  };

  # Declarative first boot: pool+bridge+profile arrive via incus-preseed
  # with zero manual `incus admin init` (a router must come up unattended).
  # boot.autostart is pinned explicitly: the daemon otherwise resumes
  # previously-running instances on its own (observed in S6 with the key
  # UNSET), and implicit behavior is not a contract.
  virtualisation.incus.preseed = {
    networks = [
      {
        name = "incusbr0";
        type = "bridge";
      }
    ];
    storage_pools = [
      {
        name = "default";
        driver = "btrfs";
        # Subvol-native pool: without an explicit source incus falls back
        # to a 5GiB loop file (fails on small disks, worse than native
        # subvolumes on btrfs anyway).
        config = {
          source = "/var/lib/incus/storage-pools/default";
        };
      }
    ];
    profiles = [
      {
        name = "default";
        config = {
          "boot.autostart" = "true";
        };
        devices = {
          eth0 = {
            name = "eth0";
            network = "incusbr0";
            type = "nic";
          };
          root = {
            path = "/";
            pool = "default";
            type = "disk";
          };
        };
      }
    ];
  };

  # Unprivileged containers use root's allocation (incusd runs as root, so a
  # same-name `incus` user would be ignored); 100000:262144 = four 64k slices.
  # newuidmap opens /etc/subuid with O_NOFOLLOW, so write real files directly.
  system.activationScripts.subuid-materialize = {
    deps = [ "etc" ];
    text = ''
      rm -f /etc/subuid /etc/subgid
      printf '%s\n' 'root:100000:262144' > /etc/subuid
      printf '%s\n' 'root:100000:262144' > /etc/subgid
      chmod 0644 /etc/subuid /etc/subgid
    '';
  };
}
