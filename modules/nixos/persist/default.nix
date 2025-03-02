{
  config,
  lib,
  inputs,
  ...
}:
let
  inherit (lib)
    escapeShellArg
    filterAttrs
    mapAttrs
    mapAttrs'
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    nameValuePair
    ;
  inherit (lib.types) listOf path str;
  inherit (builtins) concatMap;
  cfg = config.persist;
in
{
  imports = [ inputs.impermanence.nixosModules.impermanence ];

  options =
    let
      common = {
        directories = mkOption {
          type = listOf str;
          default = [ ];
        };
        files = mkOption {
          type = listOf str;
          default = [ ];
        };
      };
    in
    {
      persist = {
        enable = mkEnableOption "A tmpfs root with explicit opt-in state";
        persistRoot = mkOption {
          type = path;
          default = "/persist";
        };
        # Stuff that matters
        # TODO backups
        state = {
          # backup = {...};
        } // common;
        # Stuff that's just there to speed up the system
        cache = {
          clean = {
            enable = mkEnableOption "cleaning the cache files and directories";
            dates = mkOption {
              type = str;
              default = "weekly";
              description = "A systemd.time calendar description of when to clean the cache files";
            };
          };
        } // common;
      };
    };

  config =
    let
      # TODO: fix infinite recursion (can't get user home directory)
      # userPersists = lib.mapAttrs (name: cfg:
      #   cfg.persist // {
      #     home = config.users.users.${name}.home;
      #   }
      # ) config.home-manager.users;
      takeAll = what: concatMap (x: x.${what});
      persists = with cfg; [
        state
        cache
      ];
      allFiles = takeAll "files" persists;
      allDirectories = takeAll "directories" persists;

      userPersists = mapAttrs (_: cfg: cfg.persist) config.home-manager.users;
      usersFlatten = mapAttrs (
        name: cfg:
        let
          persists = with cfg; [
            state
            cache
          ];
          allHomeFiles = takeAll "files" persists;
          allHomeDirectories = takeAll "directories" persists;
        in
        {
          home = "/home/${name}";
          directories = allHomeDirectories;
          files = allHomeFiles;
        }
      ) userPersists;
    in
    mkIf cfg.enable {
      # Persist users uid by default
      persist.state.directories = [ "/var/lib/nixos" ];

      environment.persistence.${cfg.persistRoot} = {
        hideMounts = true;
        directories = allDirectories;
        files = allFiles;
        users = usersFlatten;
      };

      systemd.services =
        let
          filtered = filterAttrs (_: cfg: cfg.cache.clean.enable) userPersists;
        in
        mkMerge [
          (mapAttrs' (
            name: cfg:
            let
              absoluteHomePath = map (x: "/home/${name}/${x}");
            in
            nameValuePair "persist-cache-cleanup-${name}" {
              description = "Cleaning up cache files and directories for user ${name}";
              script = ''
                  ${builtins.concatStringsSep "\n" (
                    map (x: "rm ${escapeShellArg x}") (absoluteHomePath cfg.cache.files)
                  )}

                ${builtins.concatStringsSep "\n" (
                  map (x: "rm -rf ${escapeShellArg x}") (absoluteHomePath cfg.cache.directories)
                )}
              '';
              startAt = cfg.cache.clean.dates;
            }
          ) filtered)
          {
            persist-cache-cleanup = mkIf cfg.cache.clean.enable {
              description = "Cleaning up cache files and directories";
              script = ''
                ${builtins.concatStringsSep "\n" (map (x: "rm ${escapeShellArg x}") cfg.cache.files)}

                ${builtins.concatStringsSep "\n" (map (x: "rm -rf ${escapeShellArg x}") cfg.cache.directories)}
              '';
              startAt = cfg.cache.clean.dates;
            };
          }
        ];
    };
}
