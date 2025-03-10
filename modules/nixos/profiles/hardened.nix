{
  config,
  lib,
  modulesPath,
  ...
}:
let
  inherit (lib)
    mkDefault
    mkEnableOption
    mkForce
    mkIf
    mkMerge
    ;
in
{
  options.ataraxia.profiles.hardened = mkEnableOption "hardened profile";

  imports = [
    (modulesPath + "/profiles/hardened.nix")
  ];

  config = mkMerge [
    (mkIf (!config.ataraxia.profiles.hardened) {
      profiles.hardened = false;
    })
    (mkIf config.ataraxia.profiles.hardened {
      profiles.hardened = true;

      boot.kernel.sysctl = {
        "dev.tty.ldisc_autoload" = mkDefault false;
        "fs.protected_fifos" = mkDefault "2";
        "fs.protected_regular" = mkDefault "2";
        "fs.suid_dumpable" = mkDefault false;
        "kernel.printk" = mkForce "3 3 3 3";
        "kernel.sysrq" = mkDefault false;
        "kernel.yama.ptrace_scope" = mkDefault "2";
        "net.ipv4.tcp_timestamps" = mkDefault false;
        "syskernel.core_pattern" = mkDefault "|/bin/false";

        "net.ipv4.tcp_congestion_control" = mkDefault "bbr";
        "net.core.default_qdisc" = mkDefault "cake";
        "net.ipv4.conf.all.accept_source_route" = mkDefault false;
        "net.ipv4.icmp_ignore_bogus_error_responses" = mkDefault true;
        "net.ipv4.tcp_dsack" = mkDefault false;
        "net.ipv4.tcp_fastopen" = mkDefault 3;
        "net.ipv4.tcp_rfc1337" = mkDefault true;
        "net.ipv4.tcp_sack" = mkDefault false;
        "net.ipv4.tcp_syncookies" = mkDefault true;
        "net.ipv6.conf.all.accept_ra" = mkDefault false;
        "net.ipv6.conf.all.accept_source_route" = mkDefault false;
        "net.ipv6.default.accept_ra" = mkDefault false;
      };

      boot.kernelParams = [
        "lockdown=confidentiality"
        "module.sig_enforce=1"
        "oops=panic"
        "loglevel=0"
        "vsyscall=none"
      ];

      boot.blacklistedKernelModules = [
        # Obscure networking protocols
        "af_802154"
        "appletalk"
        "atm"
        "can"
        "dccp"
        "decnet"
        "econet"
        "ipx"
        "n-hdlc"
        "p8022"
        "p8023"
        "psnap"
        "rds"
        "sctp"
        "tipc"
        "x25"
        # Various rare filesystems
        "cifs"
        "gfs2"
        "hfsplus"
        "jffs2"
        "nfs"
        "nfsv3"
        "squashfs"
        "udf"
        "vivid"
        # Disable Bluetooth
        "bluetooth"
        "btusb"
        # Disable webcam
        "uvcvideo"
        # Disable Thunderbolt and FireWire to prevent DMA attacks
        "firewire-core"
        "thunderbolt"
      ];

      # "always" may incurs significant performance cost
      security.virtualisation.flushL1DataCache = "cond";
    })
  ];
}
