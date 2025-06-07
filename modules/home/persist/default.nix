{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    escapeShellArg
    mkEnableOption
    mkIf
    mkOption
    recursiveUpdate
    ;
  inherit (lib.types) listOf path str;
  inherit (builtins) concatMap;
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
          default = "/persist${config.home.homeDirectory}";
        };
        # Stuff that matters
        # TODO backups
        state = recursiveUpdate {
          # backup = {...};
        } common;
        # Stuff that's just there to speed up the system
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

  # TODO: filter persist paths like in nixos module
  config =
    let
      takeAll = what: concatMap (x: x.${what});
      persists = with cfg; [
        state
        cache
      ];
      allFiles = takeAll "files" persists;
      allDirs = takeAll "directories" persists;
    in
    mkIf cfg.enable {
      home.persistence.${cfg.persistRoot} = {
        allowOther = true;
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
          ".ssh"
          # { directory = ".ssh"; mode = "0700"; }
        ];
      };

      systemd.user = mkIf cfg.cache.clean.enable {
        services."persist-cache-cleanup-${username}" = {
          Unit = {
            Description = "Cleaning up cache files and directories for user ${username}";
            Wants = [ "modprobed-db.timer" ];
          };
          Service = {
            ExecStart = pkgs.writeShellScript "" ''
                ${builtins.concatStringsSep "\n" (
                  map (x: "rm ${escapeShellArg x}") (absoluteHomePath cfg.cache.files)
                )}

              ${builtins.concatStringsSep "\n" (
                map (x: "rm -rf ${escapeShellArg x}") (absoluteHomePath cfg.cache.directories)
              )}
            '';
            Type = "simple";
          };
          Install.WantedBy = [ "default.target" ];
        };
        timers."persist-cache-cleanup-${username}" = {
          Unit = {
            Description = "Run persist-cache-cleanup-${username} service by set schedule";
            PartOf = [ "persist-cache-cleanup-${username}.service" ];
          };
          Timer = {
            Persistent = true;
            OnCalendar = cfg.cache.clean.dates;
          };
          Install.WantedBy = [ "timers.target" ];
        };
      };
    };
}
