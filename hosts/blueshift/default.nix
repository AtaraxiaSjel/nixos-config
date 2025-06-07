{
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")

    ./backups.nix
    ./disk-config.nix
    ./services.nix
  ];

  ataraxia.defaults.role = "server";
  # Impermanence
  ataraxia.filesystems.btrfs.enable = true;
  ataraxia.filesystems.btrfs.eraseOnBoot.enable = true;
  ataraxia.filesystems.btrfs.eraseOnBoot.device = "/dev/vda4";
  ataraxia.filesystems.btrfs.eraseOnBoot.waitForDevice =
    "sys-devices-pci0000:00-0000:00:06.0-virtio2-block-vda.device";
  ataraxia.filesystems.btrfs.eraseOnBoot.eraseVolumes = [
    {
      vol = "rootfs";
      blank = "rootfs-blank";
    }
    {
      vol = "homefs";
      blank = "homefs-blank";
    }
  ];
  ataraxia.filesystems.btrfs.mountpoints = [
    "/home"
    "/nix"
    "/persist"
    "/srv"
    "/var/lib/containers"
    "/var/lib/docker"
    "/var/lib/libvirt"
    "/var/lib/podman"
    "/var/log"
  ];

  ataraxia.defaults.ssh.ports = [ 32323 ];
  ataraxia.networkd = {
    enable = true;
    disableIPv6 = true;
    domain = "ro.ataraxiadev.com";
    ifname = "enp0s3";
    mac = "00:16:3e:e3:cd:40";
    bridge.enable = true;
    ipv4 = [
      {
        address = "45.134.48.174/24";
        gateway = "45.134.48.1";
        dns = [
          "9.9.9.9"
          "149.112.112.112"
        ];
      }
    ];
  };

  services.qemuGuest.enable = lib.mkForce true;
  # I don't want to specify all required kernel modules
  # manually. For now at least
  security.lockKernelModules = lib.mkForce false;
  # scudo memalloc often borks everything
  environment.memoryAllocator.provider = lib.mkForce "libc";

  boot = {
    initrd.availableKernelModules = [
      "ata_piix"
      "uhci_hcd"
      "vfat"
      "virtio_pci"
      "virtio_scsi"
      "sd_mod"
      "sr_mod"
    ];
    kernelModules = [ "kvm-intel" ];
    kernelParams = [
      "scsi_mod.use_blk_mq=1"
      "kvm.ignore_msrs=1"
      "kvm.report_ignored_msrs=0"
      # Allow access to rescue mode with locked root user
      # "rd.systemd.unit=rescue.target"
      "systemd.setenv=SYSTEMD_SULOGIN_FORCE=1"
    ];
    kernel.sysctl = {
      # proxy tuning
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.ipv4.tcp_slow_start_after_idle" = 0;
      "net.core.default_qdisc" = "cake";
      "net.core.rmem_max" = 67108864;
      "net.core.wmem_max" = 67108864;
      "net.core.netdev_max_backlog" = 10000;
      "net.core.somaxconn" = 4096;
      "net.ipv4.tcp_syncookies" = 1;
      "net.ipv4.tcp_tw_reuse" = 1;
      "net.ipv4.tcp_fin_timeout" = 30;
      "net.ipv4.tcp_keepalive_time" = 1200;
      "net.ipv4.tcp_keepalive_probes" = 5;
      "net.ipv4.tcp_keepalive_intvl" = 30;
      "net.ipv4.tcp_max_syn_backlog" = 8192;
      "net.ipv4.tcp_max_tw_buckets" = 5000;
      "net.ipv4.tcp_fastopen" = 3;
      "net.ipv4.tcp_mem" = "25600 51200 102400";
      "net.ipv4.udp_mem" = "25600 51200 102400";
      "net.ipv4.tcp_rmem" = "4096 87380 67108864";
      "net.ipv4.tcp_wmem" = "4096 65536 67108864";
      "net.ipv4.tcp_mtu_probing" = 1;
    };
    loader.grub = {
      enable = true;
      efiSupport = true;
      efiInstallAsRemovable = true;
    };
    supportedFilesystems = [
      "vfat"
      "btrfs"
    ];
  };

  environment.systemPackages = with pkgs; [
    bat
    bottom
    git
    kitty.terminfo
    micro
    pwgen
    rsync
  ];
  services.fail2ban = {
    enable = true;
    maxretry = 3;
    bantime = "2h";
    bantime-increment = {
      enable = true;
      maxtime = "72h";
      overalljails = true;
    };
    ignoreIP = [
      "10.0.0.0/8"
      "172.16.0.0/12"
      "192.168.0.0/16"
    ];
    jails = {
      sshd.settings = {
        backend = "systemd";
        mode = "aggressive";
      };
    };
  };

  system.stateVersion = "24.11";
}
