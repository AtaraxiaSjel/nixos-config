{
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
    ./acme.nix
    ./eturnal.nix
    ./matrix.nix
  ];

  ataraxia.defaults.role = "server";
  ataraxia.defaults.locale.enable = false;
  ataraxia.defaults.zsh.enable = false;
  ataraxia.defaults.users.zshLoginShell = false;
  ataraxia.defaults.determinate.enable = false;
  ataraxia.virtualisation.libvirt = false;
  # Impermanence
  ataraxia.filesystems.btrfs.enable = true;
  ataraxia.filesystems.btrfs.eraseOnBoot.enable = true;
  ataraxia.filesystems.btrfs.eraseOnBoot.device = "/dev/vda4";
  ataraxia.filesystems.btrfs.eraseOnBoot.waitForDevice =
    "sys-devices-pci0000:00-0000:00:02.3-0000:05:00.0-virtio3-block-vda.device";
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
    domain = "matrix.ataraxiadev.com";
    ifname = "enp3s0";
    mac = "fa:16:3e:bd:96:05";
    bridge.enable = true;
    ipv4 = [
      {
        address = "46.253.132.218/32";
        gateway = "46.253.132.1";
        gatewayOnLink = true;
        dns = [ "9.9.9.11" ];
      }
    ];
  };
  virtualisation.quadlet.networks.br-services.networkConfig.dns = lib.mkForce [ "9.9.9.11" ];

  services.qemuGuest.enable = lib.mkForce true;
  security.lockKernelModules = lib.mkForce false;
  environment.memoryAllocator.provider = lib.mkForce "libc";

  boot = {
    kernelParams = [
      # "rd.systemd.unit=rescue.target"
      "systemd.setenv=SYSTEMD_SULOGIN_FORCE=1"
    ];
    kernel.sysctl = {
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
      device = "nodev";
    };
    loader.efi.efiSysMountPoint = lib.mkForce "/boot";
    loader.efi.canTouchEfiVariables = false;
    loader.limine.enable = false;
    supportedFilesystems = [
      "vfat"
      "btrfs"
    ];
  };

  environment.systemPackages = builtins.attrValues {
    inherit (pkgs)
      bat
      bottom
      micro
      rsync
      ;
  };
  services.fail2ban = {
    enable = false;
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

  system.stateVersion = "25.11";
}
