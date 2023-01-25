{ config, pkgs, lib, inputs, ... }:
let
  cfg = config.persist;

  takeAll = what: concatMap (x: x.${what});

  persists = with cfg; [ state derivative cache ];

  absoluteHomeFiles = map (x: "${cfg.homeDir}/${x}");

  allFiles = takeAll "files" persists;

  allHomeFiles = takeAll "homeFiles" persists;

  allDirectories = takeAll "directories" persists;

  allHomeDirectories = takeAll "homeDirectories" persists;

  inherit (builtins) concatMap;
  inherit (lib) mkIf;

  homeDirectory = config.home-manager.users.${config.mainuser}.home.homeDirectory;

in {
  options = let
    inherit (lib) mkOption mkEnableOption;
    inherit (lib.types) listOf path str either submodule enum;
    common = {
      directories = mkOption {
        type = listOf path;
        default = [ ];
      };
      files = mkOption {
        type = listOf str;
        default = [ ];
      };
      # homeDirectories = mkOption {
      #   type = listOf str;
      #   default = [ ];
      # };
      homeFiles = mkOption {
        type = listOf str;
        default = [ ];
      };
      homeDirectories = mkOption {
        type = listOf (either str (submodule {
          options = {
            directory = mkOption {
              type = str;
              default = null;
              description = "The directory path to be linked.";
            };
            method = mkOption {
              type = enum [ "bindfs" "symlink" ];
              default = "bindfs";
              description = "The linking method that should be used for this directory.";
            };
          };
        }));
        default = [ ];
      };
    };
  in {
    persist = {

      enable = mkEnableOption "a tmpfs root with explicit opt-in state";

      persistRoot = mkOption {
        type = path;
        default = "/persist";
      };

      homeDir = mkOption {
        type = path;
        default = homeDirectory;
      };

      # Stuff that matters
      # TODO backups of this stuff
      state = {
        # backup = {...};
      } // common;

      # Stuff that can be computed from declarative+state, but is never invalidated (so shouldn't be cleaned up)
      derivative = common;

      # Stuff that's just there to speed up the system
      # It's cleaned up regularly, to solve the cache invalidation problem once and for all
      cache = {
        clean = {
          enable = mkEnableOption "cleaning the cache files and directories";
          dates = mkOption {
            type = str;
            default = "weekly";
            description =
              "A systemd.time calendar description of when to clean the cache files";
          };
        };
      } // common;

    };
  };

  imports = [ inputs.impermanence.nixosModules.impermanence ];

  config = mkIf cfg.enable {
    # FIXME: use symlink instead of bind mounts?
    # programs.fuse.userAllowOther = true;

    environment.persistence.${cfg.persistRoot} = {
      directories = allDirectories;
      files = allFiles;
    };

    home-manager.users.${config.mainuser} = {
      imports = [ inputs.impermanence.nixosModules.home-manager.impermanence ];
      home.persistence."${cfg.persistRoot}${homeDirectory}" = {
        directories = allHomeDirectories;
        files = allHomeFiles;
        # FIXME: use symlink instead of bind mounts?
        # allowOther = true;
        allowOther = false;
        removePrefixDirectory = false;
      };
    };

    fileSystems."/" = lib.mkIf (config.deviceSpecific.devInfo.fileSystem != "zfs") {
      device = "none";
      options = [ "defaults" "size=2G" "mode=755" ];
      fsType = "tmpfs";
    };

    boot.initrd = lib.mkIf (config.deviceSpecific.devInfo.fileSystem != "zfs") {
      postMountCommands =
        assert config.fileSystems
        ? ${cfg.persistRoot}
        && config.fileSystems.${cfg.persistRoot}.neededForBoot; ''
          mkdir -p /mnt-root/nix
          mount --bind /mnt-root${cfg.persistRoot}/nix /mnt-root/nix
          chmod 755 /mnt-root
        '';
    };

    # Euuuugh
    systemd.services.persist-cache-cleanup = lib.mkIf cfg.cache.clean.enable {
      description = "Cleaning up cache files and directories";
      script = ''
        ${builtins.concatStringsSep "\n" (map (x: "rm ${lib.escapeShellArg x}")
          (cfg.cache.files
            ++ absoluteHomeFiles cfg.cache.homeFiles))}

        ${builtins.concatStringsSep "\n" (map (x: "rm -rf ${lib.escapeShellArg x}")
          (cfg.cache.directories ++ cfg.cache.homeDirectories))}
      '';
      startAt = cfg.cache.clean.dates;
    };

    # system.activationScripts = {
    #   homedir.text = builtins.concatStringsSep "\n" (map (dir: ''
    #     mkdir -p ${cfg.persistRoot}${dir}
    #     chown ${config.mainuser}:users ${cfg.persistRoot}${dir}
    #   '') (builtins.filter (lib.hasPrefix homeDirectory) allDirectories));
    # };
  };
}
