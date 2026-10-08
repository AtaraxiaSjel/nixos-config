# tachyon — closure-trimming overrides (phase 2+ of hosts/tachyon/PLAN.md).
# Flags are added one at a time; each step is built and measured with
# `nix store diff-closures` before the next one lands. A flag that breaks
# evaluation or saves ~nothing is reverted on the spot (see PLAN.md log).
{
  config,
  lib,
  pkgs,
  ...
}:
{
  # --- Iteration 2, flag 1: registry -> GitHub ---------------------------
  # Stock flake systems pin nixpkgs in /etc/nix/registry.json to the exact
  # source tree used at build time (~190 MiB nixpkgs-patched copy in the
  # closure). Pointing the registry at upstream GitHub drops that copy;
  # only on-device `nix run nixpkgs#...` UX changes (network fetch instead
  # of a pinned copy). Deployment stays flake-based from the admin machine.
  nixpkgs.flake.setFlakeRegistry = lib.mkForce false;
  # setNixPath is implemented as NIX_PATH indirection through the registry,
  # so it must go together with it. Nothing on this host consumes NIX_PATH
  # (no channels, no legacy nix-* invocations; deployment is flake-based
  # from the admin machine).
  nixpkgs.flake.setNixPath = lib.mkForce false;
  nix.registry.nixpkgs.to = {
    type = "github";
    owner = "NixOS";
    repo = "nixpkgs";
    ref = "nixos-unstable";
  };

  # --- Iteration 2, flag 2: no installer tools ---------------------------
  # Drops nixos-install / nixos-enter / nixos-generate-config and the perl
  # chain behind them. Installation happens from the admin machine or the
  # factory image, never from the device itself.
  system.disableInstallerTools = true;

  # --- Iteration 2, flag 4: nano off --------------------------------------
  # EDITOR on this host is micro (hosts/tachyon/default.nix); nano is an
  # unused default. Expected saving: a few MiB.
  programs.nano.enable = false;

  # --- Iteration 2, flag 5: LVM out of initrd ------------------------------
  # Root and all filesystems on this host are btrfs/vfat; no LVM anywhere.
  # Drops lvm2 + thin-provisioning-tools from the initrd (also keeps /boot
  # initrd small — the FAT /boot partition is 512M).
  boot.initrd.services.lvm.enable = false;

  # --- Iteration 2, flag 6: D-Bus off — REVERTED ---------------------------
  # L2 QEMU boot proved it breaks systemd-logind (repeated "Failed to start
  # User Login Management": no pam_systemd sessions, no XDG_RUNTIME_DIR)
  # and bus-dependent tooling (`networkctl status`). 2.9 MiB is not worth
  # broken session management on an SSH-administered host. Stock enabled.

  # --- Iteration 2, flag 7: suppress systemd-importd ------------------------
  # The importd unit exists only to fetch/verify container/VM images
  # (machinectl pull-tar); incus has its own image store and never touches
  # it. The unit's PATH carries gnupg, which drags openldap + bind +
  # cyrus-sasl into the closure. `suppressedSystemUnits` drops the generated
  # unit (and with it the gnupg reference) without touching the systemd
  # package itself.
  systemd.suppressedSystemUnits = [ "systemd-importd.service" ];

  # --- Small-fry audit (hosts/tachyon/PLAN.md item 4) -----------------------
  # Flag A: kexec off — REVERTED. `boot.kexec.enable = false` removes only
  # the prepare-kexec unit (-2 paths): kexec-tools itself stays, dragged in
  # by the systemd package (verified: toplevel -> systemd-260.2 ->
  # kexec-tools). Only systemdMinimal (phase 5) could evict it. Reverted
  # per the keep-or-revert rule — zero closure prize, and the flag would
  # merely disable a possibly-working feature for nothing.
  # Flag B: bcache off. `boot.bcache.enable` defaults to true and puts
  # bcache-tools in system-path + udev rules (+ initrd udev bits). SD-only
  # board, no bcache devices anywhere.
  boot.bcache.enable = false;

  # Flag C: LVM off (owner-approved). `services.lvm.enable` defaults to
  # true and pulls lvm2 (69 MB) + lvm.conf + helper scripts into the
  # closure. Zero LVM volumes on this board (all btrfs/vfat/tmpfs);
  # incus pools are btrfs-only. NOTE: libdevmapper (shipped inside the
  # lvm2 package) may still be referenced by systemd-cryptsetup linkage —
  # the diff below tells; full eviction may need withCryptsetup=false.
  services.lvm.enable = false;

  # --- Phase 5: slim systemd package (NOT systemdMinimal) -------------------
  # Full systemdMinimal is incompatible with this host: it sets
  # withNetworkd/withResolved/withLogind/withSysusers/withPolkit = false,
  # and networkd + resolved + logind + sysusers + run0/polkit are all
  # load-bearing here (verified: networkd/logind/oomd/timesyncd/vconsole
  # units wanted, `hosts: mymachines resolve ...` in nsswitch, run0 alias).
  # Instead, override the systemd package with a subset that keeps every
  # active subsystem and drops only provably-dead components. Kept true:
  # networkd, resolved, logind, sysusers, udev/kmod, pam, polkit, oomd
  # (active), timesyncd (our NTP), vconsole (keyMap=us, setup unit wanted),
  # nss (+mymachines in hosts path), machined (mymachines), userdb
  # (lastlog2-import wanted, nss-systemd in passwd path), coredump
  # (socket active), cryptsetup (round-2 candidate), hwdb (round-2),
  # everything crypto/compression stays.
  # Dropped, one line each (what it is / what we lose). None of these is
  # used by a container host either: incus/LXC is the runtime (not nspawn),
  # images come from simplestreams (not importd), updates via nixos-rebuild
  # (not sysupdate/repart), logging via container-native shippers (not
  # journal-remote). If a use case appears, reverting one line rebuilds
  # systemd with that component back.
  systemd.package = pkgs.systemd.override {
    withApparmor = false; # AppArmor policy loading; moot, kernel has no LSM.
    withAnalyze = false; # `systemd-analyze` CLI (boot plots, `verify`).
    withAudit = false; # kernel audit wiring; journal logging unaffected.
    withBootloader = false; # `bootctl`/systemd-boot; board boots extlinux.
    withDocumentation = false; # systemd man pages.
    withEfi = false; # ESP/EFI vars support; no EFI on U-Boot.
    withFido2 = false; # security-key unlock (cryptenroll); no LUKS/FIDO2.
    # NOTE: libfido2 stays via openssh (ssh-sk auth) — unrelated.
    withFirstboot = false; # factory-init wizard; image is preconfigured.
    withHomed = false; # portable LUKS homes (`homectl`); we use userborn.
    withHostnamed = false; # `hostnamectl` + API; hostname is a file.
    withImportd = false; # nspawn image pulls (`machinectl pull-tar`).
    withKexectools = false; # fast kexec reboots; untested on U-Boot.
    withLibarchive = false; # tar linkage; only served dropped components.
    withLocaled = false; # `localectl` + API; locale is a file.
    withNspawn = false; # nspawn containers; incus/LXC is the runtime.
    withPasswordQuality = false; # pw strength checks; served homed only.
    withPortabled = false; # portable service images (`portablectl`).
    withRemote = false; # journal push/pull over HTTP + curl linkage.
    withRepart = false; # declarative partition management; layout fixed.
    withShellCompletions = false; # tab-completion for systemd tools.
    withSysupdate = false; # A/B image updates; we deploy via rebuild.
    withTimedated = false; # `timedatectl` + API; timesyncd daemon KEPT,
    # so NTP still works — only the control tool is gone.
    withTpm2Tss = false; # TPM2 (measured boot, creds); no TPM on board.
    withUkify = false; # Unified Kernel Image builder; needs EFI.
    withVmspawn = false; # lightweight VMs; VMs removed entirely.
  };
  # Flag A (re-applied): with systemd's own kexec reference gone,
  # `boot.kexec.enable = false` now fully evicts kexec-tools (unit +
  # package). Verified post-build with why-depends; revert if it survives
  # via another path.
  boot.kexec.enable = false;
  # Stowaway fixes: three packages reference full pkgs.systemd at build
  # time and would keep it in the closure alongside the slim build.
  # dbus-broker (system bus, logind needs it) and zram-generator (zramSwap
  # is on: 2 GiB board) are rebuilt against the slim package — both need
  # only libsystemd. The incus daemon PATH is fixed by
  # patches/incus-slim-systemd-path.patch (same reason, fails loudly if
  # upstream rewords the list).
  services.dbus.brokerPackage = pkgs.dbus-broker.override {
    systemd = config.systemd.package;
  };
  services.zram-generator.package =
    (pkgs.zram-generator.override {
      systemd = config.systemd.package;
    }).overrideAttrs
      {
        # Upstream test suite passes (41 unit tests ok); only the test_cases
        # integration binary aborts here because this builder disallows user
        # namespaces (`unshare(NEWUSER): EINVAL` under qemu-user). The shipped
        # artifact is unaffected.
        doCheck = false;
      };

  # --- Phase 7: overlay /etc (owner-approved, needed for switch testing) --
  # Replaces the perl setup-etc.pl activation (-62.5 MiB, measured) with an
  # erofs lower + writable upper at /.rw-etc on the root subvolume.
  # mutable=true (explicit, same as upstream default): the btrfs rollback
  # wipes the upper every boot, and the /persist pins (ssh host keys,
  # machine-id) restore identity — verified stable across 3 QEMU boots.
  # mutable=false was REJECTED in QEMU (impermanence machine-id write needs
  # writable /etc -> dbus-broker crash-loop). Switch test matrix lives in
  # hosts/tachyon/switch-plan.md; the subuid persist conflict is gone
  # (persist entries replaced by static files, see virtualisation.nix).
  system.etc.overlay.enable = true;
  system.etc.overlay.mutable = true;

  # --- Phase 3: firmware subset — PREPARED, NOT ENABLED --------------------
  # Live evidence (Armbian on the same board):
  #   lspci: RTL8111/8168/8211/8411 [10ec:8168] rev 15, driver r8169.
  #   ethtool -i: firmware-version rtl8168h-2 -> blob rtl8168h-2.
  #   lspci shows NO second PCI NIC; the OpenWrt container rides a veth
  #   over the same chip, and virtual interfaces need no firmware.
  #   (This corrects the old PLAN.md assumption of "RTL8125 on r8169".)
  # Current hardware.firmware is a ~799 MiB aggregate (full linux-firmware
  # + wifi/bt/audio extras + wireless-regdb); the board has no wifi, no
  # audio, one NIC — all of it goes except the file below.
  # NOTE: this nixpkgs ships COMPRESSED firmware. Copy the .fw.zst names:
  # the kernel loader (FW_LOADER_COMPRESS, default y) resolves them for
  # the driver's plain "rtl8168h-N.fw" request. Both -1 and -2 are kept:
  # r8169 tries -2 first and falls back to -1, so a kernel bump can never
  # request a file outside this subset. (~2 KiB vs 799 MiB; the override
  # also shrinks the initrd, which pulls config.hardware.firmware.)
  # Enablement (only AFTER a live NixOS boot with FULL firmware shows no
  # "failed to load firmware" in dmesg): uncomment, rebuild with
  # `nixos-rebuild boot` (never test-switch this over SSH), keep a
  # fallback SD with full firmware nearby.
  # hardware.firmware = lib.mkForce [
  #   (pkgs.runCommand "rtl8168h-firmware" { } ''
  #     mkdir -p $out/lib/firmware/rtl_nic
  #     cp ${pkgs."linux-firmware"}/lib/firmware/rtl_nic/rtl8168h-1.fw.zst $out/lib/firmware/rtl_nic/
  #     cp ${pkgs."linux-firmware"}/lib/firmware/rtl_nic/rtl8168h-2.fw.zst $out/lib/firmware/rtl_nic/
  #   '')
  # ];
}
