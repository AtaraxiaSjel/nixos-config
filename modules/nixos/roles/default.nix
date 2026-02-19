{
  config,
  lib,
  pkgs,
  inputs,
  useHomeManager,
  ...
}:
let
  inherit (lib)
    mkDefault
    mkIf
    mkMerge
    mkOption
    mkOverride
    recursiveUpdate
    types
    ;
  mkPreferable = mkOverride 750;
  mkMorePreferable = mkOverride 75;

  defaultUser = config.ataraxia.defaults.users.defaultUser;
  fs = config.ataraxia.filesystems;
  fsCompression = fs.zfs.enable || fs.btrfs.enable;
  role = config.ataraxia.defaults.role;
in
{
  options.ataraxia.defaults = {
    role = mkOption {
      type = types.enum [
        "none"
        "base"
        "server"
        "container"
        "desktop"
        "laptop"
      ];
      default = "none";
    };
  };

  imports = [ inputs.nix-index-database.nixosModules.nix-index ];

  config =
    let
      noneRole = {
        programs.nix-index.enable = mkPreferable false;
        programs.nix-index-database.comma.enable = mkPreferable false;
      };
      containerRole = recursiveUpdate noneRole {
        ataraxia.profiles.hardened = mkDefault true;
        ataraxia.profiles.minimal = mkDefault true;

        fonts.enableDefaultPackages = false;
        fonts.fontconfig.enable = false;
        nix.optimise.automatic = mkMorePreferable false;
        persist.enable = mkPreferable false;
        time.timeZone = "Etc/UTC";
        zramSwap.enable = mkMorePreferable false;

        services.speechd.enable = false;
        services.userborn.enable = mkDefault true;
        system.rebuild.enableNg = mkDefault false;
      };
      baseRole = {
        ataraxia.defaults.boot.enable = mkDefault true;
        ataraxia.defaults.determinate.enable = true;
        ataraxia.defaults.hardware.enable = mkDefault true;
        ataraxia.defaults.locale.enable = mkDefault true;
        ataraxia.defaults.nix.enable = mkDefault true;
        ataraxia.defaults.ssh.enable = mkDefault true;
        ataraxia.defaults.users.enable = mkDefault true;
        ataraxia.defaults.zsh.enable = mkDefault (!useHomeManager);

        programs.nix-index.enable = mkDefault true;
        programs.nix-index-database.comma.enable = mkDefault true;

        persist.enable = mkDefault true;
        persist.cache.clean.enable = mkDefault true;

        # Do not compress journal logs if using native fs compression
        services.journald.extraConfig = mkIf fsCompression (mkDefault "Compress=false");
        services.speechd.enable = false;

        boot.initrd.systemd.enable = mkDefault true;
        services.userborn.enable = mkDefault true;
        system.rebuild.enableNg = mkDefault true;
        system.etc.overlay.enable = mkDefault false;
        system.etc.overlay.mutable = mkDefault true;

        systemd.services.systemd-timesyncd.wantedBy = [
          "multi-user.target"
        ];
        systemd.timers.systemd-timesyncd = {
          timerConfig.OnCalendar = "hourly";
        };

        environment.systemPackages = [
          (config.programs.git.package or pkgs.gitMinimal)
        ];

        zramSwap = {
          enable = mkPreferable true;
          algorithm = "zstd";
          priority = mkDefault 100;
          memoryPercent = mkDefault 50;
        };
      };
      serverRole = recursiveUpdate baseRole {
        ataraxia.profiles.hardened = mkDefault true;
        ataraxia.profiles.minimal = mkDefault true;
        ataraxia.virtualisation.libvirt = mkDefault true;
        ataraxia.virtualisation.podman = mkDefault true;

        boot.enableContainers = true;
        boot.supportedFilesystems = [ "nfs" ];

        fonts.enableDefaultPackages = false;
        fonts.fontconfig.enable = false;
        time.timeZone = "Etc/UTC";
        zramSwap.memoryPercent = 100;
      };
      desktopRole = recursiveUpdate baseRole {
        ataraxia.defaults.hardware.graphics = mkDefault true;
        ataraxia.defaults.sound.enable = mkDefault true;
        ataraxia.wayland.enable = mkDefault true;
        ataraxia.wayland.hyprland.enable = mkDefault true;

        programs.virt-manager.enable = config.ataraxia.virtualisation.libvirt;

        boot.supportedFilesystems = [ "nfs" ];

        # Fix some icon cache problems
        programs.gdk-pixbuf.modulePackages = with pkgs; [ librsvg ];
        services.gvfs.enable = mkDefault true;
        services.getty.autologinUser = mkDefault defaultUser;

        # allow user NFS mounts
        security.wrappers."mount.nfs4" = {
          program = "mount.nfs4";
          source = "${lib.getBin pkgs.nfs-utils}/bin/mount.nfs4";
          owner = "root";
          group = "root";
          setuid = true;
        };

        location = {
          provider = "manual";
          latitude = 48;
          longitude = 44;
        };

        zramSwap.memoryPercent = 150;
      };
      laptopRole = recursiveUpdate desktopRole {
        programs.light = {
          enable = true;
          brightnessKeys.enable = true;
          # Allow dark screen
          brightnessKeys.minBrightness = 0;
          brightnessKeys.step = 10;
        };
      };
    in
    mkMerge [
      (mkIf (role == "none") noneRole)
      (mkIf (role == "base") baseRole)
      (mkIf (role == "server") serverRole)
      (mkIf (role == "container") containerRole)
      (mkIf (role == "desktop") desktopRole)
      (mkIf (role == "laptop") laptopRole)
    ];
}
