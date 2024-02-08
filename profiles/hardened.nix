{ modulesPath, config, lib, ... }: {
  imports = [
    (modulesPath + "/profiles/hardened.nix")
  ];

  boot.kernel.sysctl = {
    "dev.tty.ldisc_autoload" = lib.mkDefault false;
    "fs.protected_fifos" = lib.mkDefault "2";
    "fs.protected_regular" = lib.mkDefault "2";
    "fs.suid_dumpable" = lib.mkDefault false;
    "kernel.printk" = lib.mkForce "3 3 3 3";
    "kernel.sysrq" = lib.mkDefault false;
    "kernel.yama.ptrace_scope" = "2";
    "net.ipv4.tcp_timestamps" = lib.mkDefault false;
    "syskernel.core_pattern" = lib.mkDefault "|/bin/false";

    "net.ipv4.tcp_congestion_control" = lib.mkDefault "bbr";
    "net.core.default_qdisc" = lib.mkDefault "cake";
    "net.ipv4.conf.all.accept_source_route" = lib.mkDefault false;
    "net.ipv4.conf.all.log_martians" = false;
    "net.ipv4.conf.all.rp_filter" = "0";
    "net.ipv4.conf.default.log_martians" = false;
    "net.ipv4.conf.default.rp_filter" = "0";
    "net.ipv4.icmp_ignore_bogus_error_responses" = lib.mkDefault true;
    "net.ipv4.tcp_dsack" = lib.mkDefault false;
    "net.ipv4.tcp_fastopen" = lib.mkDefault 3;
    "net.ipv4.tcp_rfc1337" = lib.mkDefault true;
    "net.ipv4.tcp_sack" = lib.mkDefault false;
    "net.ipv4.tcp_syncookies" = lib.mkDefault true;
    "net.ipv6.conf.all.accept_ra" = lib.mkDefault false;
    "net.ipv6.conf.all.accept_source_route" = lib.mkDefault false;
    "net.ipv6.default.accept_ra" = lib.mkDefault false;
  };

  boot.kernelParams = [
    "debugfs=off"
    "lockdown=confidentiality"
    "module.sig_enforce=1"
    "oops=panic"
    "quiet" "loglevel=0"
    "slab_nomerge"
    "vsyscall=none"
  ];

  boot.blacklistedKernelModules = [
    # Obscure networking protocols
    "dccp"
    "sctp"
    "rds"
    "tipc"
    "n-hdlc"
    "x25"
    "decnet"
    "econet"
    "af_802154"
    "ipx"
    "appletalk"
    "psnap"
    "p8023"
    "p8022"
    "can"
    "atm"
    # Various rare filesystems
    "jffs2"
    "hfsplus"
    "squashfs"
    "udf"
    "cifs"
    "nfs"
    "nfsv3"
    "gfs2"
    "vivid"
    # Disable Bluetooth
    "bluetooth"
    "btusb"
    # Disable webcam
    "uvcvideo"
    # Disable Thunderbolt and FireWire to prevent DMA attacks
    "thunderbolt"
    "firewire-core"
  ];

  # security.lockKernelModules = false;
  security.allowSimultaneousMultithreading = true;
  security.virtualisation.flushL1DataCache = "cond";
  # security.forcePageTableIsolation = false;

  # scudo memalloc is unstable
  environment.memoryAllocator.provider = lib.mkDefault "scudo";
  # environment.memoryAllocator.provider = lib.mkDefault "graphene-hardened";

  # dhcpcd broken with scudo or graphene malloc
  nixpkgs.overlays = lib.optionals (config.environment.memoryAllocator.provider != "libc") [
    (_final: prev: {
      dhcpcd = prev.dhcpcd.override { enablePrivSep = false; };
    })
  ];
}