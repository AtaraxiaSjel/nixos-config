# tachyon — NanoPi R3S LTS: minimal closure plan

Goal: smallest possible system closure without losing the functionality
needed on this device. Target state: base + SSH + incus
(containers only, no virtual machines).

Metric: `nix path-info -Sh <toplevel>` (closure size), path count,
initrd/kernel size (`/boot` budget is 512M FAT), factory `.img` size.
Baseline gcroot: `/tmp/opencode/tachyon-baseline`
(store path `9fhhdgpsfgxk4g7m51v266gjm32iky3z-nixos-system-tachyon-26.05pre-git`).

## Baseline (Phase 0, measured, no config changes)

- Closure: **2.1 GiB, 530 paths**. initrd 29 MiB (fits /boot easily).
- Top offenders (verified NAR sizes):
  - `linux-firmware` 799 MiB (via `hardware.firmware` aggregate `firmware`)
  - `nixpkgs-patched` sources 197 MiB (via `etc/nix-registry.json`)
  - `linux-6.18.51` 188 MiB + `linux-modules` 126 MiB
  - `python3` 132 MiB (only via `nixos-rebuild-ng` <- `system-path`)
  - `systemd` full 77 MiB + `systemd-minimal` 29 MiB (system runs full)
  - `perl` 57 MiB (via installer tools: nixos-install/enter/option/...)
  - `glibc` 45 MiB (base, stays), `icu4c` 39 MiB (via boost <- nix, stays)
  - `gnupg` 14 MiB + `openldap` + `bind` ~25 MiB total via `systemd-importd`
  - `micro` 13 MiB (chosen editor, stays)
  - small fry: `cryptsetup`, `lvm2`, `man-db`+`groff`, `nano`, `sudo` pkg,
    full `bind`, `fuse2/3`, `bcache-tools`, `kexec-tools`, `tpm2-tss`
- Already lean: locales trimmed (3 MiB), `security.sudo.enable=false`,
  docs/fonts off, `nix.optimise.automatic=false`.
- Chains proven with `nix why-depends`: python3 <- nixos-rebuild-ng;
  perl <- installer tools; gnupg/openldap/bind <- systemd-importd;
  dbus-1 <- /etc (no polkit service in closure); nixpkgs sources <- registry.

## Iterations

### 1. incus: price it (base -> base+incus) — DONE, see log

- `hosts/tachyon/incus.nix`: stock `virtualisation.incus.enable = true`
  only. No `ui.enable`, no `preseed`, no sops secrets yet.
- Check: build + `nix store diff-closures` vs baseline (L0 only).
- Follow-ups decided after measuring:
  - qemu: stock module hardcodes `pkgs.qemu_kvm`, `qemu-utils`, `swtpm`,
    OVMF/AAVMF, `seabios`, `virtiofsd` etc. into the daemon PATH/wrapper.
    Containers-only host does not need them; dropping qemu while keeping
    incus likely means a custom unit instead of the stock module.
    Investigate, then decide.
  - `ui.enable` (`incus-ui-canonical`): price separately, decide after.

### 2. Safe batch (seven one-liners in `hosts/tachyon/minimal.nix`)

1. Registry -> GitHub URL (`nix.registry.nixpkgs.to`, pinned to input rev):
   -197 MiB sources, keeps `nix run` UX over network.
2. `system.disableInstallerTools = true`: kills installer tools + perl
   stack (~-60..100 MiB).
3. `system.tools.nixos-rebuild.enable = false`: kills nixos-rebuild-ng +
   python3 (~-130..150 MiB). Deploy stays `--target-host` from admin box.
4. `programs.nano.enable = false` (~-3 MiB, micro stays).
5. `boot.initrd.services.lvm.enable = false` (btrfs-only layout).
6. `services.dbus.enable = false` (no consumers; re-check vs incus deps).
7. Suppress `systemd-importd` (kills gnupg/openldap/bind, ~-20..30 MiB).

- Check each flag with its own `diff-closures`; then L1 (mkImage, /boot
  fit) + L2 (QEMU: stage-1, btrfs migration, networkd, sshd, incus unit).

### 3. Firmware subset — SNIPPET READY (enable only after live verification)

- Replace full `linux-firmware` (~799 MiB) with a two-file package
  (`rtl8168h-{1,2}.fw.zst`, ~2 KiB). Snippet lives commented in
  `hosts/tachyon/minimal.nix`.
- Live evidence (Armbian on the same board): single PCI NIC
  RTL8111/8168 [10ec:8168] rev 15, driver r8169, ethtool firmware-version
  rtl8168h-2; NO second PCI NIC (the OpenWrt container rides a veth over
  the same chip — virtual interfaces need no firmware). This corrects the
  old "RTL8125 on r8169" assumption below.
- Verified in nixpkgs: firmware ships compressed (.fw.zst, kernel resolves
  them automatically); initrd pulls `config.hardware.firmware`, so the
  override shrinks stage-1 too; `pkgs."linux-firmware"` contains the files.
- Enablement gate: first live NixOS boot with FULL firmware must show no
  "failed to load firmware" in dmesg; then uncomment + `nixos-rebuild boot`
  (never test-switch over SSH), fallback SD ready.

### 4. Small-fry audit (~-10..30 MiB)

- Find the source of: `sudo` pkg in system-path, full `bind`, `fuse2/3`,
  `bcache-tools`, `kexec-tools`, `cpupower`, `libressl`, `mkpasswd`,
  `resize`. One confirmation per item before touching.

### 5. `systemd.package = pkgs.systemdMinimal` (~-40..50 MiB)

- Medium risk (udev/hwdb/sysusers on minimal); L2 + hardware test.
  One-line revert.

### 6. Custom kernel (~-150..250 MiB), last

- `linuxPackages_custom` from board kernel config minus headless excess
  (drm/gpu/vpu, media, usb-audio, wifi/bt; keep r8169, btrfs, netfilter,
  virtio for QEMU, zram). Native build only (remote builder TBD).

## Standing rules

- Tachyon changes only in `hosts/tachyon/*.nix` + one import line in
  `default.nix`. Shared `modules/` untouched.
- `git add -N` for every new file under `hosts/tachyon/` (flake visibility).
- All repo work in English, comments included.
- No change without explicit approval; each phase ends with: report +
  next-phase sketch in chat, appended below.

## Log

- Phase 0: baseline 2.1 GiB / 530 paths. gcroot /tmp/opencode/tachyon-baseline.
- Iteration 1: stock `virtualisation.incus.enable = true`
  (+ `networking.nftables.enable = true`, hard requirement
  of the incus module: it asserts against iptables).
  Result: **2.1 GiB / 530 paths -> 3.9 GiB / 826 paths (+1.8 GiB, +296)**.
  Biggest additions (closure deltas): `qemu-host-cpu-only` 370 MiB,
  `OVMF` 328 MiB (AAVMF on aarch64), `incus-lts` 275 MiB, `skopeo` 30 MiB,
  `qemu-utils` 27 MiB. Direct VM-only package set (qemu, OVMF, swtpm,
  virtiofsd, criu, skopeo, umoci, xdelta, cdrkit, gptfdisk, xfsprogs,
  thin-provisioning, virglrenderer, spice, vde2, ...) sums to **>=794 MiB**
  NAR — lower bound of the prize for a containers-only setup (qemu's
  exclusive libs such as x264/x265/zenity/vte come on top).
  `incus-ui-canonical` priced separately: **+20 MiB, single path** (decision pending).
  nftables itself: +1.3 MiB; `iptables` package NOT removed
  (stays — audit in iter 4).
  Network audit: stack already networkd-native (useNetworkd, resolved,
  timesyncd on; dhcpcd/resolvconf off). Only static `etc-resolvconf.conf` remains.
- Decisions: nftables mandatory (router policy: modern stack only);
  firmware subset ON HOLD (no serial access, network is critical) — keep
  the snippet commented with a note; repo work in English.
- Iteration 1b (surgery + UI): `patches/incus-containers-only.patch`
  (containers-only incus module) +
  `virtualisation.incus.ui.enable = true` + one line in flake `patches`.
  Patch generated mechanically via `diff -U3`
  from a scripted edit (hand-written hunks proved brittle against patch(1);
  verify any future rebase by apply + byte-compare + `nix-instantiate --parse`).
  Result: **3.9 GiB / 826 paths -> 2.4 GiB / 560 paths (-1.5 GiB, -266)**.
  Net vs baseline: 2.1/530 -> 2.4/560 (+0.3 GiB for incus+lxc+dnsmasq+UI+nftables).
  Removed: qemu-host-cpu-only 370, OVMF 328, qemu-utils 27, skopeo 30, umoci 7,
  incus doc 36 (via dropped INCUS_DOCUMENTATION), spice/swtpm/virtiofsd/criu.
  Added: incus-ui-canonical +19. Closure grepped clean: zero refs to
  qemu/OVMF/seabios/swtpm/virtiofsd/spice/criu/skopeo/umoci (incl. unit file refs).
  Conscious losses: --vm, docker: OCI import, stateful snapshots, LVM/ext4/XFS
  pool tools, lego ACME, iw, `incus documentation`, VM console.
  Shared-tree check: orion evaluates fine on the repatched tree. pulsar FAILS
  evaluation, but pre-existing and unrelated (`systemd.sleep.extraConfig`
  removed upstream; hosts/pulsar/server.nix needs `systemd.sleep.settings.Sleep`).
- Iteration 2a (flag 1: registry -> GitHub + setNixPath off): repo's own
  `flake-module.nix` pins `setFlakeRegistry=true`, so plain assignment
  conflicts — needed `lib.mkForce false` on BOTH setFlakeRegistry and
  setNixPath (latter asserts on the former; NIX_PATH unused on this host).
  Result: **2.4 GiB / 560 -> 2.2 GiB / 559 (-197 MiB, -1 path)** — the whole
  delta is exactly `nixpkgs-patched` removed, nothing else moved. KEEP.
- Iteration 2b (flag 2: `system.disableInstallerTools = true`): **2.2 GiB /
  559 -> 2.1 GiB / 541 (-18 paths)**. Removed: python3 131.3 (!) +
  groff 10.2 + man-db 2.1 + perl partial 2.2 + odds.
  Surprise: flag 2 ALSO removed
  `nixos-rebuild-ng` + the whole python3 chain (expected for flag 3) — in
  this nixpkgs the rebuild wrapper rides with the installer tools, so flag 3
  is likely a no-op (verify, then revert the line per the keep-or-revert rule).
  Perl remnant (perl 5.42 + File::Slurp, ~3 MB) traced to `setup-etc.pl` —
  the CORE /etc activation script, structural NixOS floor, not removable by
  flags. KEEP flag 2.
- Iteration 2c (flag 3: `system.tools.nixos-rebuild.enable = false`): EMPTY
  diff vs iter2b (identical toplevel hash) — flag 2 had already removed the
  wrapper in this nixpkgs. REVERTED per the keep-or-revert rule (one line
  less, same closure).
- Iteration 2d (flag 4: `programs.nano.enable = false`): **541 -> 538 paths**,
  -13.0 MiB (nano 2.6 + libmagic `file` 10.4). KEEP.
- Iteration 2e (flag 5: `boot.initrd.services.lvm.enable = false`): closure
  paths unchanged (538), initrd -929 KiB. No lvm2 in the system closure even
  before (only initrd carried it). KEPT despite the small delta: zero risk
  (btrfs-only host) and initrd size is an explicit /boot-fit concern for L1.
- Iteration 2f (flag 6: `services.dbus.enable = mkForce false`): **538 ->
  524 paths**, ~-2.9 MiB (dbus 0.9 + broker 0.5 + expat 0.3 + c-* libs +
  initrd -0.5). No assertion failures from any module. KEEP.
- Iteration 2g (flag 7: `systemd.suppressedSystemUnits =
  [ "systemd-importd.service" ]`): **524 -> 515 paths, 2.1 -> 2.0 GiB
  (~-20 MiB: gnupg 13.7 + openldap 5.1 + assuan/ksba/usb/npth)**. The unit's
  `path = [ pkgs.gnupg ]` was the ONLY reference holding gnupg in the
  closure (confirmed: zero gnupg/openldap/cyrus-sasl refs left). Two bind
  survivors (`bind.lib`, `bind.host`) traced to `pkgs.host` in
  `environment.corePackages` from nixpkgs `tasks/network-interfaces.nix`
  (UNCONDITIONAL, no flag). `pkgs.host` == bind's `host` output; its closure
  is ~80 MiB (mostly shared libs). Removing it = fighting an upstream
  default (overlay stub or list surgery) AND losing dig/host on a ROUTER —
  left as optional flag 8 for the owner to decide. KEEP flag 7.
- Iteration 2h (flag 6 REVERTED): L2 boot proved `services.dbus.enable =
  false` breaks systemd-logind (6x "Failed to start User Login Management":
  no pam_systemd sessions, no XDG_RUNTIME_DIR) and bus tooling
  (`networkctl status`: "Failed to connect to system bus"). 2.9 MiB is not
  worth broken session management on an SSH-administered host. Production
  final: **2.0 GiB / 529 paths** (iter1b 2.4/560 -> final: -31 paths,
  ~-390 MiB, removals only). Vs Phase-0 baseline (2.1/530): net -0.1 GiB
  WITH incus containers-only + UI + nftables on board.
- L1 (factory image via board `lib.mkImage`, no VM): image builds cleanly
  from the trimmed config. Layout verified with fdisk: 16M loader gap,
  p1 512M FAT (`BOOT`), p2 btrfs. /boot FIT: 211 of 512 MiB used (Image
  64M + initrd 28M + extlinux + full dtbs dir; DTB subset = future opt).
  extlinux.conf correct: LINUX/INITRD/FDT
  (rk3566-nanopi-r3s.dtb), init= points at the built toplevel.
- L2 (qemu-system-aarch64 -machine virt, TCG, direct -kernel boot): three
  rounds. R1 failed at `initrd-find-nixos-closure` — TEST HARNESS bug, not
  system bug: init= pointed at a toplevel absent from the image store
  (image predates the probe variant); fixed by rebuilding the image from
  the probe config. R2 full boot: migration OK, networkd/sshd/incus
  active, sshd :22, but eth0 unmanaged (production matches wan0/lan0;
  expected) and the "missing" incus socket. R3 (dbus reverted + eth0 DHCP
  test net + socket/API checks): ALL GREEN — migration layout exact,
  eth0 `routable configured` + online via DHCP, networkd/sshd/incus/logind
  active, :22 on v4+v6, `networkctl status` works, ZERO logind failures,
  `incus.socket` listening at **/var/lib/incus/unix.socket** (StateDir, not
  /run — that was the R2 "mystery"), `incus query /1.0` full JSON
  (QUERY-RC:0), clean `poweroff -f`. Daemon warnings on record: no
  /etc/subuid (FOLLOW-UP: configure subUidRanges for the container owner),
  AppArmor off (board kernel), qemu driver not operational (by design, no
  KVM in test; VMs removed anyway). Probe scaffolding
  (`hosts/tachyon/l2probe.nix` + import) DELETED after the test;
  production config rebuild verified after deletion.
- Unprivileged containers (follow-up closed): root ranges
  `root:100000:262144` via static `environment.etc` subuid/subgid
  (+2 paths, ~0 bytes). `users.users.*.subUidRanges` is DEAD under userborn
  (classic activation skipped; systemd-sysusers has no subid support —
  verified in nixpkgs source), and a same-name `incus` user would be
  ignored by the daemon ("System idmap (root user)" in the binary).
  Store-backed files, rollback-proof, no persist entry needed.
- system.etc.overlay investigated (subagent, code + nixpkgs issues): experimental,
  hardcoded paths, erofs lower + upper at `/.rw-etc` ON THE ROOT FS.
  Blockers for us: #319524 (enabling wipes old /etc: ssh keys/shadow, lockout),
  upper wiped by our blank-snapshot rollback (machine-id/hostkeys/password/DUID
  churn every boot), #303262/#333999 (remount/umount busy), #505475 (stale
  whiteouts hide new entries). perlless win is only ~3 MiB (setup-etc.pl).
  VERDICT: deferred to after phase 3, QEMU-gated with mitigations (persistent
  machine-id + /etc/ssh on /persist, fixed DUID, boot-not-switch enablement).
- Phase 3 (firmware): live Armbian evidence collected over SSH (lspci,
  ethtool -i, /lib/firmware listing, full lspci -nnk — single 8168H NIC,
  no second PCI device, empty firmware grep = nothing missing).
  Commented subset snippet added to `hosts/tachyon/minimal.nix`
  (rtl8168h-{1,2}.fw.zst via runCommand + mkForce, ~2 KiB vs 799 MiB);
  evaluation verified unchanged (commented = no-op). Awaiting live NixOS
  dmesg confirmation before enabling.
- Small-fry audit (item 4): baseline re-measured 2.0 GiB / 531 paths
  (+2 = static subuid/subgid). Every item traced with `nix why-depends`:
  - `sudo` in system-path is NOT sudo: 704-byte bash script `exec run0`,
    systemd's run0 sudo-alias (`security.run0.enableSudoAlias`, set by the
    ataraxia run0 module). KEEP, intentional.
  - kexec-tools <- `boot.kexec.enable` (default true). Flagged off: removes
    ONLY the prepare-kexec unit (-2 paths) — the package stays, dragged in
    by the systemd package itself (toplevel -> systemd-260.2 ->
    kexec-tools). REVERTED per keep-or-revert (zero prize); noted for
    phase 5 (systemdMinimal may evict it).
  - bcache-tools <- `boot.bcache.enable` (default true). Flagged off:
    CLEAN removal, -221.6 KiB + initrd -48.2 KiB (udev bits), no second
    referrer. KEPT (`boot.bcache.enable = false`).
  - cpupower <- cpufreq.service <- board sets
    `powerManagement.cpuFreqGovernor = mkDefault "schedutil"`. Functional
    power management (the only power lever on this board). KEEP.
  - libressl + nc <- `environment.corePackages` "netcat" (unconditional,
    no flag); libressl's ONLY consumer is nc (verified). Removal needs a
    full corePackages override (~30 lines, fights upstream). PROPOSAL.
  - mkpasswd <- same corePackages list, tiny. Bundled with the nc proposal.
  - `resize` shell script <- srvos common/serial.nix (serial auto-resize,
    functional on the ttyS2 board console; script itself is bytes,
    coreutils stays anyway). KEEP.
  - fuse2/fuse3 + fusermount wrappers + fuse.conf <-
    `programs.fuse.enable` (default true). KEEP: the incus CLI execs sshfs
    (`main.sshfsMount`, "Failed starting sshfs", ".sshfs mounting") for
    `incus file` pull/push — sshfs needs fusermount at runtime. Removing
    fuse would break core container management.
  - sshfs <- incus unit PATH: live runtime dep (see above), 151 KiB. KEEP.
  - bind-host + bind-lib (lib NAR 4.4 MiB) <- pkgs.host in corePackages
    (unconditional). Flag 8 RESOLVED: owner needs dig — KEEP, closed.
  - netcat + mkpasswd: owner unsure about nc — PARKED, left in place. If
    revisited: full corePackages override evicts libressl (3.5 MiB, sole
    consumer is nc, verified) + nc + mkpasswd.
- Phase 5 (systemd, KEPT): full `systemdMinimal` is INCOMPATIBLE — it sets
  withNetworkd/withResolved/withLogind/withSysusers/withPolkit=false, all
  load-bearing here (networkd/logind/oomd/timesyncd/vconsole wanted,
  `hosts: mymachines resolve ...` in nsswitch, run0 alias). Instead a
  targeted `systemd.package` override (21 flags, `hosts/tachyon/minimal.nix`):
  drops apparmor/analyze/audit/bootloader+efi/docs/fido2/firstboot/homed/
  hostnamed+localed+timedated/importd/kexectools/libarchive/nspawn/
  passwordquality/portabled/remote/repart/completions/sysupdate/tpm2/ukify/
  vmspawn. Kept: networkd, resolved, logind, sysusers, udev/kmod, pam,
  polkit, oomd+timesyncd (active), vconsole (keyMap=us), nss+machined
  (mymachines in hosts path), userdb (lastlog2-import wanted), coredump
  (socket active), cryptsetup/hwdb (round-2 candidates).
  - qrencode NOT droppable: stage-1 hard-requires systemd-bsod
    (initrd.nix upstreamUnits + storePaths) — `initrd-units.drv` fails
    the build otherwise. bsod stays.
  - Stowaways: full systemd stayed via dbus-broker (system-path),
    zram-generator, and three incus unit PATHs (module uses bare
    pkgs.systemd). Fixed: brokerPackage + zram-generator rebuilt against
    the slim package; incus PATH via new
    `patches/incus-slim-systemd-path.patch` (wired in flake.nix, fails
    loudly if upstream rewords the list).
  - zram-generator tests: 41 unit tests pass; integration binary aborts on
    `unshare(NEWUSER): EINVAL` (this builder disallows userns under
    qemu-user) — environmental, `doCheck=false` with comment.
  - Prize: **531 -> 519 paths (~-29 MiB) + initrd -4.4 MiB**. Removed:
    full systemd (-13.4 package delta), tpm2-tss -4.0, gnutls -3.6
    (journal-remote chain, already meson-off), libtpms -1.2, unbound -1.1,
    libevent -1.0, cracklib -824K, libpwquality -473K, kexec-tools -297K
    (Flag A combo worked: 0 kexec refs left), libmicrohttpd -283K.
    Legit survivors: curl (elfutils<-coredump), libfido2 (openssh-sk),
    libarchive (nix). No DNS capability lost (gnutls was already off).
    Lost from PATH: hostnamectl/localectl, analyze, bootctl; `systemctl
    kexec` now fails cleanly.
  - Gate: static check over all 75 wanted units (60 Exec paths, no
    dangling wants) PASSES. Live QEMU deferred to the deploy gate —
    combine with phase-3's live boot (firmware dmesg + systemd health in
    one session, fallback SD ready).
- Closure audit (2.16 GB NAR / 519 paths): firmware 837 MB (39%),
  kernel+modules 327, incus 251+25+UI 20 (workload), perl 59 (sole job:
  setup-etc.pl at activation — perlless REQUIRES system.etc.overlay, so
  the overlay prize is ~60 MB not ~3 MB; still deferred/QEMU-gated),
  nix tax ~57 (boost+icu; no nix-minimal knob, structural), systemd
  63+libs (trimmed), glibc 46 (locales already C+en_US only, 2.9 MB),
  lvm2 69 MB with services.lvm on and zero LVM volumes (READY FLAG),
  glib 16.7 (sshfs, locked), util-linux-minimal 13 (fuse libmount, probe),
  hwdb.bin 13.6 (round-2 withHwdb), hwdata 10 (incus-path pciutils +
  cpupower dep; cpupower live-gated on rk3566 cpufreq driver), micro 13
  (owner-chosen editor, stays), e2fsprogs 5.3 (via btrfs-convert, parked),
  db 4.4 (iproute2, parked). Realistic floor after ready+gated actions:
  ~1.1 GB; sub-1 GB needs overlay+perlless.
- Flag C (lvm, owner-approved, APPLIED): `services.lvm.enable = false`.
  Correction: saves ~3 MB, not 69 (69 was closure size incl. shared deps;
  lvm2 ships split outputs, the bins were 2.7 MB NAR). lvm2-lib
  (libdevmapper) stays via cryptsetup <- slim systemd; stub lvm.conf stays
  unconditionally (upstream tasks/lvm.nix, bytes). Full eviction needs
  withCryptsetup (round-2). -4 paths (519 -> 515).
- Container-role verdicts: oomd/resolved/coredump/machined kept (oomd more
  valuable with containers on 2 GB); nspawn/journal-remote stay dropped
  (one-line reverts); micro stays (chosen editor, default.nix:91); incus
  UI stays. cpupower stays: Armbian lsmod shows cpufreq_dt (scaling works,
  Armbian just lacks the tool).
- Incus 251 MB anatomy: Go binaries ~218 MB (incusd 59, cli 23, migrate 18,
  simplestreams 18, lxc/lxd-to-incus 32, benchmark 16, generate-db 16,
  incus-user 15, fuidshift 7...) + share/agent 14 MB. Module uses only
  incusd/incus/incus-user: postInstall-rm candidate ~-100 MB (needs a Go
  rebuild — parked, not built yet).
- Phase-6 inputs (Armbian lsmod on the same board): KEEP r8169,
  dwmac_rk+stmmac+pcs_xpcs+realtek PHY (2nd NIC, no firmware), tun,
  wireguard stack, FULL nft set (tproxy/queue/socket/redir/nat/masq/ct
  used!), veth, zram, fuse, i2c/rtc_rk808/pmic/fan53555/rk805_pwrkey,
  crct10dif_ce, cpufreq_dt, uas/usb-storage bundle (ports exist). DROP
  snd_*, cfg80211/rfkill (no WiFi HW), sunrpc (no NFS planned), ext4 stack
  (Armbian-rootfs artifact), rk_crypto2/sm3?, binfmt_misc+autofs, sg?.
  vhost/vsock (VM-only) dropped only if deploy gate proves `incus exec`
  clean. amneziawg = out-of-tree module, compat vs 6.18 checked in phase
  6. Version: 6.18 LTS recommended (uptime + existing pin + armbian
  rockchip64 as patch/config source); 7.x = new bugs + patch/awg lag.
- Overlay reframed: prize is ~60 MB perl (perlless REQUIRES overlay),
  not 3 MB. mutable=false CANCELLED by owner (switch->boot-only deploys
  unacceptable on a serial-less router). mutable=true trial planned:
  risk refined — user auth keys are build-baked (safe), only runtime files
  at risk (host keys -> pin via services.openssh.hostKeys to /persist,
  already a repo pattern; machine-id -> persist bind, verify in QEMU).
  QEMU experiment on owner go-ahead.
- Incus slim via copy-repack (hosts/tachyon/incus.nix): runCommand copies
  the cached package minus 6 binaries (migrate/simplestreams/lxc+ lxd-to-
  incus/benchmark/generate-database) — **-94.4 MiB, 47s build** (vs 30-min
  failed emulated Go rebuild: 16 parallel qemu-user compiles, almost
  certainly OOM — log ends abruptly at buildPhase start, no error).
  Lesson: file-removal trims via copy (closure-safe, static Go), never via
  overrideAttrs recompile; symlinkJoin would NOT save closure (keeps ref).
  Gotcha: module defaults clientPackage to package.client — passthru
  re-attached. Daemon unit verified -> slim/bin/incusd, original package
  0 refs. Leftover micro-helpers kept: generate-config, sysinfo.
- Diagnostics: host x86_64-linux, aarch64 via binfmt+qemu-user 10.2.4;
  substituters incl. cache.nixos.org + ataraxia-builds.cachix.org (own).
  Prior builds were fast = upstream aarch64 cache hits; only our overrides
  compile locally (emulated). No custom binary cache yet (planned).
- Builder decision (RU constraints: Oracle blocked, Hetzner likely too):
  kernel = cross on the 16-core x86 (pure Kbuild, 10-20 min, no target
  exec); GHA = batch-only (workflow -> cache -> substitute, awkward dev
  loop); local ARM SBC (Orange Pi 5 class) = best interactive if volume
  grows. Full-system cross impossible (long tail executes target code).
- Overlay QEMU slot (owner go-ahead, DONE): probe `overlay-probe.nix`
  (deleted after; factory image via mkImage + direct -kernel boot, virtio/
  ttyAMA0/eth0-DHCP, ephemeral SSH key, serial log + QMP powerdown).
  - Closure prize CONFIRMED: perl 5.42.0 -62.5 MiB + File::Slurp + setup-etc.pl
    gone; added etc-metadata.erofs 36 KiB + initrd +144 KiB (virtio/erofs/
    overlay). Net ~-62 MiB, both round to 1.9 GiB.
  - Harness bugs hit + fixed: (1) init= passed as /tmp symlink — guest
    find-etc resolves inside /sysroot, must be the /nix/store path
    (emergency mode, same family as L2 R1); (2) bootspec forensics: the
    overlay build carries etc_basedir/etc_metadata_image under
    org.nixos.nixos-init.v1 (bootspec.v1 has no etc keys).
  - Cell 1 mutable=true: GREEN 3/3 boots (migration, rollback, rollback).
    --failed EMPTY, is-system-running=running, overlay mount exactly per
    upstream (lowerdir=erofs::basedir, upperdir=/.rw-etc). sshd/networkd/
    incus.socket/logind/getty/userborn active, DHCP online. machine-id,
    DUID-EN and ed25519 hostkey fingerprint IDENTICAL across all 3 boots
    (impermanence + /persist pins work). Victim file v1 present after every
    rollback (upper wipe clean). userborn writes passwd/group/shadow to
    upper (shadow 000 = normal sysusers behavior, not a bug).
  - Cell 2 mutable=false: REJECTED. Impermanence machine-id special-case
    assumes writable /etc (touch+bind) -> persist unit fails on ro overlay
    -> no /etc/machine-id -> dbus-broker crash-loops, guest hangs at 39s
    (kill -9, powerdown ignored), SSH never comes. Plus Register-Nix-Paths
    fails (writes to /etc). Immutable needs upstream work (baked machine-id
    or ro-aware impermanence) + userborn-on-ro story: not our slot.
  - PRE-EXISTING REPO BUG exposed (not overlay-caused, blocks green gate):
    modules/nixos/virtualisation/virtualisation.nix unconditionally persists
    /etc/subuid+subgid (podman heritage; no host DECLARES subUidRanges, but
    andromedae carries LIVE content `ataraxia:100000:65536` — pre-userborn
    leftover pinned in persistent storage, load-bearing for its rootless
    user quadlet cc-proxy; orion is rootful-only, files unneeded there).
    Under
    overlay they exist as non-empty LOWER files -> impermanence mount-file
    `-s` guard ("A file already exists!") fails the units (mutable boot1 was
    degraded until probe-scoped `persist.state.files = mkForce
    ["/etc/machine-id"]`). Production fix = condition the declaration on
    `!config.system.etc.overlay.enable` (touches modules/, owner decision;
    andromedae keeps its working binds — rootless cc-proxy depends on them;
    on tachyon persistence is actively harmful: static build-baked content +
    rollback restore it anyway). andromedae hygiene (optional): the
    range is accidental — pin `ataraxia:100000:65536` explicitly if ever
    touched (container storage ownership depends on it); /var/lib/nixos
    group/passwd/shadow (Jul 2025) are dead under userborn, safe to rm.
  - Accepted gaps: live `switch` path untested (out of policy: boot-only
    enablement); rm-as-root whiteout untested (no root in guest; rollback
    wipe proven, switch path out of policy). Minor notes: /etc/subuid mode
    777 in lower (environment.etc default, pre-existing); QMP system_powerdown
    works when guest healthy, ignored when hung.
  - PROPOSAL (no approval yet, NOT applied): enable in minimal.nix
    `system.etc.overlay.enable = true` (mutable default true) AFTER the
    modules/ persist fix; enable via `boot` + fallback SD, never switch.
- NTFS call: NixOS default with ntfs support = ntfs3g (FUSE)
  (tasks/filesystems/ntfs.nix) — follow it for RW safety + keep kernel
  ntfs3 as module (free unless mounted, faster reads). erofs+overlayfs
  added to phase-6 keep-list (overlay lower!). hfsplus dropped, podman =
  later (incus-only now), vanilla 6.18 LTS confirmed.
  not 3 MB. QEMU experiment proposed as its own slot (image + mitigations:
  persist machine-id+/etc/ssh, fixed DUID, boot-not-switch; check
  activation/units/whiteouts/reboot). Production enablement still needs
  fallback SD + no-serial caution.
- SWITCH-UPDATE SLOT S0..S5 — VERDICT: switch updates VIABLE, 5/6 green
  (S1 red understood + fixed). S0 harness green (A boot, baselines).
  S1 RED: A'->B switch hung (ordering cycle tmpfiles<->basic via
  nix-daemon.socket + userborn boot-only + /nix UID-1000 ownership) ->
  fallback boot B2 GREEN. Fixes APPLIED in tree: nix-store-ownership
  chown, ordering DefaultDependencies=false+after local-fs, userborn-resync
  activation. S2 GREEN x4 switches (userborn-resync proven, sshd/networkd
  never restarted, identity stable); whiteout expectation CORRECTED:
  upstream clear-etc-opaque preserves file whiteouts by design
  (etc_overlay.rs, same issue #505475) — deletion sticky across switches,
  wiped on reboot. S3 GREEN + 1 real bug: shadow>=4.19 newuidmap opens
  /etc/subuid O_NOFOLLOW -> ELOOP on NixOS store symlinks (strace-proven,
  all 4.19/4.20 builds; host too) -> unprivileged incus dead on arrival.
  Fix APPLIED: subuid-materialize activation (rm + cp --remove-destination
  after etc), proven live incl. clean-boot. NOTE: host rootless podman
  works only because it joins a PRE-EXISTING userns (setns-traced, no fresh
  mapping); first fresh mapping post-upgrade FAILS the same way — shared
  virtualisation.nix still ships the bare symlink (owner call). S4 GREEN:
  broken oneshot contained (RC=4, only victim failed), recovery D->E RC=0
  with --failed self-clearing, no reboot. S5 GREEN: F boots to S0 bar,
  fixes live from clean boot. LESSON: direct switch-to-configuration never
  updates /nix/var/nix/profiles/system (nixos-rebuild's job) — prod flow
  must include nix-env --set (board register-nix-paths heals it at boot:
  nix-env --set /run/current-system). CORRECTION: the no-degraded scare
  about that unit was my misread — it HAS ConditionPathExists since the
  board repo's initial commit (verified live), consumed trigger = clean
  skip. No board change needed. FINDING for owner stands: /var rolls
  back at boot -> /var/lib/incus wiped (s3test gone) -> prod call:
  persist incus state vs cattle-redeploy.
  Guest left RUNNING on F (wnl98072) for inspection; dead probes deleted,
  qemu probe still imported (final prod cleanup = remove it + rebuild).
- POST-SLOT (owner-directed): shared subuid now DIRECT-WRITE (activation
  printf, no environment.etc step anywhere — shared module for
  podman/docker, incus.nix for root:100000:262144; one-sentence comments).
  /var/lib/incus = top-level /incus subvol (disko + idempotent initrd
  ensure). S6 DONE GREEN on H (pcrg1m6r): subvol created from inside guest
  (host has no btrfs-progs/sudo), switch F->H mounted it, fresh btrfs pool +
  unprivileged alpine s6c with uid_map 0/100000/262144 (ELOOP path
  proven on the new scheme), REBOOT into H: S0-bar intact, daemon healthy
  with no manual restart (switch-time shadowing was a switch-only
  artifact), s6c auto-resumed RUNNING with boot.autostart UNSET (observed,
  not configured — set explicitly in prod if deterministic boot wanted),
  uid_map re-verified post-reboot, then s6c STOPPED (data kept on subvol).
  Guest left RUNNING on H for inspection.
- S7 BACKUP (owner-directed, on J=ly6dkymg): app-level round-trip GREEN —
  `incus export s6c` 4.6MB/2.2s to /persist, delete, import 1.5s, start,
  alpine 3.21.7 + uid_map 0/100000/262144. Fs-level send/receive: 7MB
  stream in 0.14s BUT restores only daemon DB/config — nested subvols
  (pools/images/containers) are silently omitted, so plain `btrfs send`
  of /incus is NOT a workload backup; verdict: per-instance export is
  the primary path (off-device copy still needed for real DR — /persist
  is same-SD). Zero-touch first boot: wiped /var/lib/incus (nested
  subvols need bottom-up `subvolume delete`, image subvols are ro —
  `rm -rf` alone leaves them), reboot into I: preseed FAILED first try
  (btrfs pool without source defaults to 5GiB loop file — too big;
  fixed with explicit source=/var/lib/incus/storage-pools/default,
  subvol-native). On J, preseed re-applied: pool+incusbr0+profile
  (autostart=true) with zero manual init; import from /persist tarball
  → RUNNING. Note: switch does NOT retry a failed oneshot preseed
  (needed manual restart after the fix; fresh boot runs it once — the
  prod case).   Guest RUNNING on J, s6c STOPPED, tarball kept in /persist.
- CLEANUP DONE (owner-directed): switch-probe-qemu.nix import dropped +
  file deleted (git records AD). Final toplevel K (0bnbwkxi, 1.99 GiB):
  no switch-victim, no 99-qemu-eth0, rootKeys=[], deploy back on
  production ssh-rsa (ephemeral ed25519 mkForce gone). K is build-verified
  only — it cannot boot in this QEMU harness (no virtio_blk/ttyAMA0/eth0
  adaptation anymore) and no switch test (SSH keys + NICs are prod now);
  next boot is real hardware. Owner notes: 5 phases incl. systemdMinimal
  DONE, only custom kernel left (later); andromedae rebuild+reboot by
  owner; backup scripts on prod iron.
- nixpkgs ELOOP issue: no upstream issue exists; draft at
  /tmp/opencode/nixpkgs-subuid-eloop-issue.md (O_NOFOLLOW ancient ≤4.8.1,
  4.19 only added the message via shadow#1254; classic NixOS hid it via
  update-users-groups.pl; only nixpkgs acknowledgment is userborn
  #508608 bind-mount).
- PHASE 6 KERNEL v1 DONE (owner-directed, pre-first-boot cross x86_64->aarch64):
  hosts/tachyon/kernel/{package.nix,delta-v1.conf,upstream-6.18/} +
  flake perSystem tachyon-kernel (NOT in system). Stock armbian
  rockchip64-6.18 (3472-line fragment + 197 patches + 62 dt + overlays,
  vendored 1:1) on nixpkgs 6.18.51. Gotchas fixed: cachyos shadows
  linux_* (pristine legacyPackages), top-level linux_6_18 IS the drv,
  perSystem sees only inputs', merged configfile needs
  allowImportFromDerivation (else isModular=false, no modules), dtb
  Makefile register loop (r3s-lts.dtb was missing). Delta v1 (5 lines):
  DRM=n, WIRELESS=n, WLAN=n (WLAN default-y selects WIRELESS -- also
  explains the 6.12 WIRELESS=y drift), OVERLAY_FS=y, HFS/HFSPLUS=n.
  Timed: T1 19m / T2 17m / v1 15.5m / v1b 14m. Result: 0 patch rejects,
  intent 5/5, modules 3113 (was 3569), Image 34.6M, both r3s dtbs.
  QEMU smoke (-machine virt, serial): 88/89 identical boots to
  "VFS: Unable to mount root fs" panic (no rootfs by design), 0
  oops/BUG/WARNING, Not tainted. Next: wire into system + fallback-SD.
- PHASE 6 KERNEL REWORK (owner-directed): no more vendored armbian files.
  armbian-build is now a flake input pinned to commit a7d6467 (2026-09-23,
  git+https rev, flake=false; full-tree fetch ~186M one-time, ~9M used).
  Tag v26.5.1 REJECTED as pin: 4 months older than main (178 vs 197
  patches, config +/-20 lines) -- would lose fixes and invalidate the
  verified baseline; revisit stable tag at next maintenance. Previous
  vendored tree (400 files) parked in stash@{0} "exp: tachyon kernel v1b" +
  tarball /tmp/opencode/tachyon-kernel-v1b-backup.tar.gz (no commit).
  Rollback: `git stash pop` (+ `git checkout flake.nix flake.lock`).
  NO IFD: config merged as strings at eval (readFile input+delta),
  materialized via writeText (build-time dep), parsed with nixpkgs'
  readConfig regex passed as explicit `config` (customPackage can't
  forward it -- manualConfig+packagesFor called directly; inputs' is
  flake-only, source input via plain `inputs`). Repo now carries only
  hosts/tachyon/kernel/{package.nix,delta-v1.conf}. Rebuild v2 15.5m:
  0 rejects, result .config BYTE-IDENTICAL to v1b
  (/tmp/opencode/kernel-v1b-result.config), same Image size; QEMU rerun
  skipped (identical config+src). tachyon-kernel KEPT in flake (builds
  must come from somewhere; remove when parking the experiment).
- PHASE 6 KERNEL BAKED (owner-directed): hosts/tachyon/kernel.nix (imported
  in default.nix) wires the custom kernel into the system: boot.kernelPackages
  = pkgs.linuxPackagesFor over flake packages.x86_64-linux.tachyon-kernel
  (cross-built aarch64 Image+modules consumed as data, standard pattern);
  hardware.deviceTree.name mkForce-flipped to rockchip/rk3566-nanopi-r3s-
  lts.dtb (our kernel ships it; kernelPackage defaults to our kernel);
  boot.initrd.availableKernelModules = board list minus 6 DRM modules
  (analogix_dp rockchipdrm dw_hdmi dw_hdmi_cec dw_hdmi_i2s_audio dw_mipi_dsi)
  -- DRM=n, and the initrd builder fails hard on missing modules
  (allowMissing=false). Per-module modprobe --show-depends vs the built
  kernel proved the other 20 resolve (builtin/.ko/aliases); rockchip-rga
  stays (=m V4L2). Coverage audit of the result .config: zram/btrfs/fuse/
  tun/veth/wireguard/nft-full/ipv6/bridge/i2c/HYM8563-RTC/mmc/dm-crypt all
  present (two initial ABSENTs were my wrong symbol guesses: NF_TABLES,
  RTC_DRV_HYM8563).
  Bake bug (NOT from the flake-input rework, would hit any fragment
  configfile): config/sysctl.nix greps configfile for ARCH_MMAP_RND_*_MAX
  (only such consumer in nixos/modules) -- fragment lacks Kconfig defaults
  -> 55-nixos-aslr-entropy.conf failed. Fixed with 2 pinned lines in
  delta-v1.conf (33/16 from our resolved .config; explicit=default, result
  .config still BYTE-identical to v1b). Toplevel ha52y6sb... BUILT (~33m on
  loaded host): kernel+modules+shrunk ok, initrd has exactly the right 18
  .ko (r8169/realtek/btrfs+deps/snps-pcie3/rga+v4l2/dm-mod, rest builtin,
  zero DRM), aslr conf 33/16, closure 1.8 GiB (was ~2.0). Factory image
  rebuilt via board mkImage (tachyon.img 4.2G/1.1G xz, layout intact):
  extlinux LINUX/INITRD/FDT all ours, FDT=lts.dtb, /boot used ~58M of 512M
  (was 211M). Next: real hardware boot (fallback SD ready); firmware subset
  still gated on live dmesg; amneziawg OOT later (wiki pattern banked).
