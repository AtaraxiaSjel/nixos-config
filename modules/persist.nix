{ config, lib, inputs, ... }:
let
  cfg = config.persist;

  takeAll = what: concatMap (x: x.${what});

  persists = with cfg; [ state derivative cache ];

  absoluteHomePath = map (x: "${cfg.homeDir}/${x}");

  allFiles = takeAll "files" persists;

  allHomeFiles = takeAll "homeFiles" persists;

  allDirectories = takeAll "directories" persists;

  allHomeDirectories = takeAll "homeDirectories" persists;

  inherit (builtins) concatMap;
  inherit (lib) mkIf;

  homeDirectory = config.home-manager.users.${config.mainuser}.home.homeDirectory or "/home/${config.mainuser}";
in {
  options = let
    inherit (lib) mkOption mkEnableOption;
    inherit (lib.types) listOf path str;

    common = {
      directories = mkOption {
        type = listOf str;
        default = [ ];
      };
      files = mkOption {
        type = listOf str;
        default = [ ];
      };
      homeFiles = mkOption {
        type = listOf str;
        default = [ ];
      };
      homeDirectories = mkOption {
        type = listOf str;
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
    environment.persistence.${cfg.persistRoot} = {
      hideMounts = true;
      directories = allDirectories;
      files = allFiles;
      users.${config.mainuser} = {
        home = "/home/${config.mainuser}";
        directories = allHomeDirectories;
        files = allHomeFiles;
      };
    };

    systemd.services.persist-cache-cleanup = lib.mkIf cfg.cache.clean.enable {
      description = "Cleaning up cache files and directories";
      script = ''
        ${builtins.concatStringsSep "\n" (map (x: "rm ${lib.escapeShellArg x}")
          (cfg.cache.files
            ++ absoluteHomePath cfg.cache.homeFiles))}

        ${builtins.concatStringsSep "\n" (map (x: "rm -rf ${lib.escapeShellArg x}")
          (cfg.cache.directories ++ absoluteHomePath cfg.cache.homeDirectories))}
      '';
      startAt = cfg.cache.clean.dates;
    };

    # system.activationScripts = {
    #   homedir.text = builtins.concatStringsSep "\n" (map (dir: ''
    #     mkdir -p ${cfg.persistRoot}${dir}
    #     chown ${config.mainuser}:users ${cfg.persistRoot}${dir}
    #   '') (
    #     (builtins.filter (lib.hasPrefix cfg.homeDir) allDirectories)
    #       ++ absoluteHomePath allHomeDirectories
    #   ));
    # };
  };
}
