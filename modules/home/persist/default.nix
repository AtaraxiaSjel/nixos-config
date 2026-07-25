{
  config,
  lib,
  pkgs,
  customLib,
  ...
}:
let
  inherit (lib)
    escapeShellArg
    isAttrs
    mkEnableOption
    mkIf
    mkOption
    recursiveUpdate
    ;
  inherit (lib.types)
    listOf
    path
    str
    ;
  inherit (builtins) concatMap;
  inherit (customLib.persist) filterCacheFiles generateCacheDirCleanup;

  cfg = config.persist;
  username = config.home.username;
  homeDir = config.home.homeDirectory;
  absoluteHomePath = map (x: "${homeDir}/${x}");

in
{
  options =
    let
      common = {
        directories = mkOption {
          type = listOf str;
          default = [ ];
          description = "List of directories to persist.";
          example = [
            ".config/foo"
            ".config/bar"
          ];
        };
        files = mkOption {
          type = listOf str;
          default = [ ];
          description = "List of files to persist.";
          example = [ ".config/foo.conf" ];
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
        # TODO backups
        state = recursiveUpdate {
          # backup = {...};
        } common;
        cache = recursiveUpdate {
          clean = {
            enable = mkEnableOption "cleaning the cache files and directories";
            dates = mkOption {
              type = str;
              default = "weekly";
              description = "A systemd.time calendar description of when to clean the cache files";
            };
          };
        } common;
      };
    };

  config =
    let
      takeAll = what: concatMap (x: x.${what});
      persists = with cfg; [
        state
        cache
      ];
      allFiles = takeAll "files" persists;
      allDirs = takeAll "directories" persists;

      # Helper function to extract path strings from the mixed list
      getPaths = map (x: if isAttrs x then x.directory else x);
    in
    mkIf cfg.enable {
      home.persistence.${cfg.persistRoot} = {
        # allowOther = true;
        directories = allDirs;
        files = allFiles;
      };

      # Persist by default
      persist.cache.directories = [ ".cache" ];
      persist.state = {
        directories = [
          "Downloads"
          "Documents"
          "Music"
          "Pictures"
          "Videos"
          ".config/dconf"
          ".local/share/nix"
          ".local/share/systemd"
          ".ssh"
        ];
      };

      systemd.user = mkIf cfg.cache.clean.enable {
        services."persist-cache-cleanup-${username}" = {
          Unit = {
            Description = "Cleaning up cache files and directories for user ${username}";
          };
          Service =
            let
              # Extract only the path strings for the cleanup script
              cacheDirPaths = getPaths cfg.cache.directories;
              absoluteStateDirs = absoluteHomePath (getPaths cfg.state.directories);
              absoluteStatePaths = absoluteStateDirs ++ (absoluteHomePath cfg.state.files);

              cleanCacheFiles = filterCacheFiles (absoluteHomePath cfg.cache.files) (absoluteHomePath (
                getPaths cfg.state.directories
              )) (absoluteHomePath cfg.state.files);
            in
            {
              ExecStart = pkgs.writeShellScript "" ''
                ${builtins.concatStringsSep "\n" (
                  map (x: "${pkgs.coreutils}/bin/rm ${escapeShellArg x}") cleanCacheFiles
                )}

                ${builtins.concatStringsSep "\n" (
                  map (x: generateCacheDirCleanup x absoluteStatePaths) (absoluteHomePath cacheDirPaths)
                )}
              '';
              Type = "simple";
            };
        };
        timers."persist-cache-cleanup-${username}" = {
          Unit.Description = "Run persist-cache-cleanup-${username} service by set schedule";
          Timer = {
            Persistent = true;
            OnCalendar = cfg.cache.clean.dates;
          };
          Install.WantedBy = [ "timers.target" ];
        };
      };
    };
}
