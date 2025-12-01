{
  lib,
  pkgs,
  modulesPath,
  ...
}:
let
  confluence = pkgs.stdenvNoCC.mkDerivation {
    name = "confluence-webpage";
    src = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/Jolymmiles/confluence-marzban-home/893b46b06f69379505da68d7b2298c333e9d2513/index.html";
      hash = "sha256-2ARMM6lf6f7BH0hwxOYgMOEn8yzzGgFtKLJgii3J6/w=";
    };
    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -p $out
      cp -r $src $out/index.html
    '';
  };
in
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];

  ataraxia.defaults.role = "server";
  ataraxia.defaults.locale.enable = false;
  ataraxia.defaults.zsh.enable = false;
  ataraxia.defaults.users.zshLoginShell = false;
  ataraxia.virtualisation.libvirt = false;
  # Impermanence
  ataraxia.filesystems.btrfs.enable = true;
  ataraxia.filesystems.btrfs.eraseOnBoot.enable = true;
  ataraxia.filesystems.btrfs.eraseOnBoot.device = "/dev/vda4";
  ataraxia.filesystems.btrfs.eraseOnBoot.waitForDevice =
    "sys-devices-pci0000:00-0000:00:07.0-virtio5-block-vda.device";
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
    domain = "drive.ataraxiadev.com";
    ifname = "ens3";
    mac = "52:54:00:07:d3:8c";
    bridge.enable = true;
    ipv4 = [
      {
        address = "64.188.70.125/32";
        gateway = "172.16.0.1";
        gatewayOnLink = true;
        dns = [ "9.9.9.9" ];
      }
    ];
    ipv6 = [
      {
        address = "2a12:bec4:1bb0:10dc::/64";
        gateway = "2a12:bec4:1bb0:10dc::1";
        gatewayOnLink = true;
        dns = [ "2620:fe::fe" ];
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
    kernelParams = [
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
      nh
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

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  ataraxia.services.tor.enableRelay = true;
  ataraxia.services.tor.relayPort = 17351;
  ataraxia.containers.remnawave-node.enable = true;
  services.caddy = {
    enable = true;
    configFile = pkgs.writeText "Caddyfile" ''
      {
          https_port 4123
          default_bind 127.0.0.1
          servers {
              listener_wrappers {
                  proxy_protocol {
                      allow 127.0.0.1/32
                  }
                  tls
              }
          }
          auto_https disable_redirects
      }
      https://drive.ataraxiadev.com {
          root * ${confluence}
          file_server
      }
      http://drive.ataraxiadev.com {
          bind 0.0.0.0
          redir https://drive.ataraxiadev.com{uri} permanent
      }
      :4123 {
          tls internal
          respond 204
      }
      :80 {
          bind 0.0.0.0
          respond 204
      }
    '';
  };

  system.stateVersion = "25.05";
}
