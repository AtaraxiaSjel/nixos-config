# tachyon — switch-test strategy for overlay /etc

Status: APPROVED by owner, STARTED (S0 in progress).
Process requirement: a BRIEF REPORT to the owner after EVERY phase (S0..S5).
Testing is long; the owner does not want to sit blind for hours.

## Why

Router uptime requirement: `boot`-only updates are REJECTED. All config/
userspace updates must go through `switch`. Kernel updates still need a
reboot (no kexec on U-Boot; out of scope) — see "Residual risks".

## Context (from the overlay QEMU slot, hosts/tachyon/PLAN.md)

- Mutable overlay (`system.etc.overlay.enable`, mutable=true): GREEN 3/3
  QEMU boots (migration, rollback, rollback). Zero failed units, sshd/
  networkd/incus.socket/logind healthy, machine-id + DUID-EN + ssh hostkey
  fingerprint identical across boots, upper wipe clean on rollback.
- Immutable (mutable=false): REJECTED (impermanence machine-id write needs
  writable /etc -> dbus-broker crash-loop, guest hang). Not revisited here.
- Closure prize confirmed: perl -62.5 MiB, +36 KiB erofs +144 KiB initrd.
- PREREQUISITES (BOTH APPLIED, better than proposed):
  1. DONE (supersedes the mkIf suggestion): the unconditional
     `/etc/subuid+subgid` persist declaration in
     `modules/nixos/virtualisation/virtualisation.nix` was REMOVED entirely
     and replaced by static `environment.etc` files under `mkIf (podman ||
     docker)`. No overlay condition needed (static files are overlay-safe);
     andromedae static content verified byte-identical to its live binds.
  2. DONE: overlay enabled in `hosts/tachyon/minimal.nix` (enable + mutable,
     both explicit).
- Switch path itself is UNTESTED (out of policy in the boot slot). This file.

## Harness (reuse of the overlay slot, qemu-system-aarch64 -machine virt)

- Probe v2 (`hosts/tachyon/switch-probe.nix`, TEMPORARY, delete after):
  overlay enable + mutable, virtio modules, `console=ttyAMA0`,
  `net.ifnames=0`, serial getty, eth0 DHCP network, ephemeral deploy key,
  PLUS root SSH key (switch-to-configuration needs root; the boot slot had
  no root access) and the whiteout victim file.
- Factory image via board mkImage (same command as the boot slot):
  `nix build --impure --expr 'let cfg = builtins.getFlake
  "/home/ataraxia/nixos-config"; in
  cfg.inputs.nixos-nanopi-r3s.lib.mkImage { pkgs =
  cfg.inputs.nixpkgs.legacyPackages.x86_64-linux; model = "r3s-lts"; system
  = cfg.nixosConfigurations.tachyon; fs = "btrfs";
  imageName = "tachyon-switch-<gen>"; }'`
- QEMU: `-machine virt -cpu cortex-a72 -m 2048 -smp 4 -display none
  -serial file:<log> -kernel <STORE>/kernel -initrd <STORE>/initrd -append
  "init=<STORE>/init console=ttyAMA0 net.ifnames=0" -drive
  file=<disk>,format=raw,if=virtio -nic
  user,model=virtio-net-pci,hostfwd=tcp::2222-:22 -qmp tcp:127.0.0.1:4445,server,nowait`.
  LESSON FROM BOOT SLOT: init= MUST be the resolved /nix/store path
  (a /tmp symlink kills the boot: find-etc resolves inside /sysroot).
- Generation delivery: build gen B/C/D toplevels on the host, `nix copy
  --to ssh://root@127.0.0.1:2222 <store-path>`, then `ssh root@guest
  /nix/store/<gen>/bin/switch-to-configuration switch`. Guest nix-daemon
  runs by default; root over SSH is trusted.
- Instrumentation per switch: continuous serial log, `journalctl -b`,
  checks (failed units, `is-system-running`, `findmnt /etc`, /etc content
  diff vs expected, `ls /.rw-etc/upper`, unit ActiveEnterTimestamp
  before/after for sshd/networkd, DUID, machine-id, `incus list`), plus a
  persistent SSH-mux connection and slirp ping across the switch to prove
  zero-drop.

## Phases

### S0 — harness bring-up

Boot image A (overlay probe v2) fresh. Expect boot green like cell 1.
Record baselines: machine-id, DUID, hostkey fingerprint, unit timestamps.
Gate: --failed empty, SSH root+deploy. REPORT.

### S1 — first enablement via switch (issue #319524 risk) — DONE WITH FALLBACK (RED)

Outcome: switch A'->B hung post-daemon-reload, SSH died. Two root causes:
R1: fresh overlay upper has no passwd/group/shadow (userborn is boot-only,
switch restarts only changed units) -> sshd user gone by design. Fix APPLIED
(system.activationScripts.userborn-resync, deps=[etc], in B2).
R2: the S0 nix-ownership fix (Before=tmpfiles-setup with default deps) closed
an ordering cycle (tmpfiles-setup -> fix -> basic -> sockets -> nix-daemon.socket
-> tmpfiles-setup); systemd deleted tmpfiles-setup's job -> /var/empty,
/var/run, daemon-socket never created -> sshd+nscd dead. This retro-explains
ALL red boots (Aprme disk x2, B). Fix APPLIED (DefaultDependencies=false +
after=local-fs). B2 (with both fixes) booted GREEN from image = the
pre-approved boot enablement. Steady-state switches (incl. userborn-resync
proof) move to S2 on B2.

Image A' = production + qemu-only probe WITHOUT overlay. Boot, record.
nix-copy gen B (overlay), switch. The danger: runtime /etc state
(passwd/shadow from userborn, machine-id bind, hostkeys in /persist,
DHCP lease) must survive the lower+empty-upper replacement.
Gate: getent both users, pre-switch SSH session alive, networkd NOT
restarted (timestamps), same DUID/lease, --failed empty. Fallback if red:
one scheduled `boot` enablement, switches only after. REPORT.

### S2 — steady-state switches + whiteouts — DONE (GREEN, corrected)

B2->C (15s), C->B2, B2->C, C->B2(final): all clean. userborn-resync PROVEN
(users resolve after every switch into a fresh upper); sshd/networkd NEVER
restarted (timestamps frozen since boot); sleep PID survived 3 switches;
machine-id/DUID stable; --failed empty, running. Whiteout case: file
whiteouts PERSIST across switches — this is UPSTREAM DESIGN, not a bug:
nixos-init etc_overlay.rs documents "individual whiteouts are preserved"
(only stale dir-opaque markers are cleared), citing issue #505475 itself.
The plan's "must REAPPEAR" expectation was wrong; corrected: deletion is
sticky across switches, wiped on reboot (upper wipe, S5 re-verifies).

B->C (add a file via environment.etc), C->B (remove; file must vanish),
whiteout case as root: rm a lower file under B, switch to C where it
changed -> must REAPPEAR (clear-etc-opaque path, issue #505475).
Gate: only changed units restart; control `sleep` + SSH-mux survive;
upper diff matches expectation. REPORT.

### S3 — incus continuity across switch — DONE (GREEN, +1 real bug found & fixed)

Unprivileged alpine started only AFTER fixing newuidmap ELOOP: shadow
opens /etc/subuid with O_NOFOLLOW, NixOS ships it as a store symlink ->
forklxc exit 1 (standalone repro). Fix APPLIED hosts/tachyon/default.nix:
activationScripts.subuid-materialize (rm + cp --remove-destination after
etc, same pattern as userborn-resync), proven live C->E with pre-restored
symlink state. Switches under container load (B2->C, C->E): zero ts gaps,
PID1 starttime frozen, incusd never restarted. NOTE for owner: same
breakage likely hits rootless podman/LXC on any 26.05 host (shared
virtualisation.nix only writes the symlink) — shared-module call is yours.

Under B: launch unprivileged alpine (exercises the static subuid!),
verify networked. Switch B->C (unit/package unchanged or changed — test
both if cheap). Verify: socket responsive, same `incus list`, container
ping keeps flowing. Also confirm our containers-only patch kept
softDaemonRestart semantics. Gate: zero container downtime. REPORT.

### S4 — failure drill — DONE (GREEN)

E->D(broken oneshot): switch RC=4 naming the victim, current-system=D,
ONLY victim failed, degraded, container+SSH untouched. D->E recovery:
RC=0, --failed EMPTY without reset-failed, running, victim unit gone,
container P1 frozen, ts gapless. No reboot at any point.

Gen D with a broken non-critical unit. Switch B->D: system stays
manageable (SSH in, journal readable), then switch back to B green.
Gate: recoverability without reboot. REPORT.

### S5 — switch, then reboot — DONE (GREEN, +2 prod findings)

E->F switch RC=0 (F==E store path, probe removal = no-op rebuild).
CRITICAL harness lesson: direct switch-to-configuration NEVER touches
/nix/var/nix/profiles/system (profile = nixos-rebuild's job; activate
only sets /run/current-system). Pre-reboot profile still pointed at B2!
Reboot into F: S0 bar met (running, 0 failed, victim v1, users via
fresh-upper userborn, subuid REAL files from clean boot via
subuid-materialize, machine-id b627b3c7/DUID/hostkey stable, no etc
journal errors). Profile healed to F at boot by the BOARD module
(register-nix-paths.service: nix-env --set /run/current-system) —
CORRECTION (my earlier scare was wrong): the unit HAS had
ConditionPathExists=/nix-path-registration since the board repo's
initial commit (verified live in guest), so the consumed trigger means
clean SKIP, not failure — no degraded, no board change needed.
FINDING 2 stands: /var rolls back at boot — /var/lib/incus wiped
(s3test gone) -> prod call: persist incus state vs cattle-redeploy.

Reboot into the switched generation. Expect: clean boot, upper rebuilt
from the new lower, persist binds reapplied, identity stable.
Gate: same bar as S0 on the new generation. REPORT.

### Cleanup (after S5 green)

Delete probe(s), remove import, verify production rebuild hash equals the
pre-test production toplevel, append results to PLAN.md, drop a final
summary. Update the enablement proposal (switch vs boot for S1).

## Global success criteria

Every phase: --failed empty (modulo the EXPECTED S4 breakage),
is-system-running=running, /etc content == generation expectation,
machine-id/DUID/hostkeys stable, no SSH/ping drop outside S4.

## Residual risks (not closed by this plan)

- Kernel updates = reboot, always (kexec disabled, no livepatch infra).
  Batch LTS point releases into rare scheduled windows.
- extlinux timeout=1 with no serial = blind fallback on the router.
  Consider raising the timeout (production change, owner decision).
- Switch stress under real container load is sampled (one alpine), not
  exhaustive.
