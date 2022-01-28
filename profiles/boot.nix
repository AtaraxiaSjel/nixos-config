{ lib, pkgs, config, ... }:
with config.deviceSpecific; {
  boot = if !isServer then {
    loader = {
      timeout = lib.mkForce 4;
      systemd-boot.enable = pkgs.system == "x86_64-linux";
    };

    kernelParams = [ "quiet" "scsi_mod.use_blk_mq=1" "modeset" "nofb" ]
      ++ lib.optionals (pkgs.system == "x86_64-linux") [
        "rd.systemd.show_status=auto"
        "rd.udev.log_priority=3"
        "pti=off"
        "spectre_v2=off"
      ];

    kernelPackages = pkgs.linuxPackages_zen;

    supportedFilesystems = [ "ntfs" ];

    extraModprobeConfig = lib.mkIf (config.device == "AMD-Workstation") ''
      options snd slots=snd_virtuoso,snd_usb_audio
    '';

    consoleLogLevel = 3;
    kernel.sysctl = {
      "vm.swappiness" = if config.deviceSpecific.isSSD then 1 else 10;
    };
  } else {
    kernelPackages = pkgs.linuxPackages_5_15_hardened;
    kernelModules = [ "tcp_bbr" ];
    kernel.sysctl = {
      "kernel.sysrq" = 0;
      "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
      "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
      "net.ipv4.conf.default.rp_filter" = 1;
      "net.ipv4.conf.all.rp_filter" = 1;
      "net.ipv4.tcp_syncookies" = 1;
      "net.ipv4.conf.all.accept_redirects" = 0;
      "net.ipv4.conf.default.accept_redirects" = 0;
      "net.ipv4.conf.all.secure_redirects" = 0;
      "net.ipv4.conf.default.secure_redirects" = 0;
      "net.ipv6.conf.all.accept_redirects" = 0;
      "net.ipv6.conf.default.accept_redirects" = 0;
      "net.ipv4.conf.all.send_redirects" = 0;
      "net.ipv4.conf.all.accept_source_route" = 0;
      "net.ipv6.conf.all.accept_source_route" = 0;
      "net.ipv4.tcp_rfc1337" = 1;
      "net.ipv4.tcp_fastopen" = 3;
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.core.default_qdisc" = "cake";
    };
  };
}
