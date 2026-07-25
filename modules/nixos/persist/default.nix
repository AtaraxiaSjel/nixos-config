{
  config,
  lib,
  pkgs,
  inputs,
  customLib,
  ...
}:
let
  inherit (lib)
    escapeShellArg
    hasPrefix
    mkEnableOption
    mkDefault
    mkIf
    mkOption
    recursiveUpdate
    unique
    ;
  inherit (lib.types) listOf path str;
  inherit (builtins) any concatMap filter;
  cfg = config.persist;

  btrfs = config.ataraxia.filesystems.btrfs.mountpoints;
  zfs = config.ataraxia.filesystems.zfs.mountpoints;
  mountpoints = unique (btrfs ++ zfs);
  subtractListsPrefix = a: filter (dir: !(any (pref: hasPrefix pref dir) a));

  inherit (customLib.persist) filterCacheFiles;
  generateCacheDirCleanup = customLib.persist.generateCacheDirCleanup pkgs;
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

  config =
    let
      takeAll = what: concatMap (x: x.${what});
      persists = with cfg; [
        state
        cache
      ];
      allFiles = takeAll "files" persists;
      allDirectories = takeAll "directories" persists;
      # Remove btrfs + zfs mountpoints from list of dirs to persist
      filteredDirs = subtractListsPrefix mountpoints allDirectories;
    in
    mkIf cfg.enable {
      environment.persistence.${cfg.persistRoot} = {
        allowTrash = false;
        hideMounts = true;
        directories = filteredDirs;
        files = allFiles;
        # users = usersFlatten;
      };

      programs.fuse.userAllowOther = mkDefault true;

      systemd.services.persist-cache-cleanup = mkIf cfg.cache.clean.enable {
        description = "Cleaning up cache files and directories";
        script =
          let
            stateDirs = cfg.state.directories;
            stateFiles = cfg.state.files;
            statePaths = stateDirs ++ stateFiles;

            cleanCacheFiles = filterCacheFiles cfg.cache.files cfg.state.directories cfg.state.files;
          in
          ''
            ${builtins.concatStringsSep "\n" (
              map (x: "${pkgs.coreutils}/bin/rm ${escapeShellArg x}") cleanCacheFiles
            )}

            ${builtins.concatStringsSep "\n" (
              map (x: generateCacheDirCleanup x statePaths) cfg.cache.directories
            )}
          '';
        startAt = cfg.cache.clean.dates;
      };

      fileSystems.${cfg.persistRoot}.neededForBoot = true;
      # TODO: need to check if this is necessary
      fileSystems."/home".neededForBoot = true;

      services.openssh.hostKeys = [
        {
          path = "/persist/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
        {
          path = "/persist/etc/ssh/ssh_host_ecdsa_key";
          type = "ecdsa";
        }
        {
          path = "/persist/etc/ssh/ssh_host_rsa_key";
          type = "rsa";
          bits = 4096;
        }
      ];
      # Persist by default
      persist.cache.directories = [
        "/var/cache"
      ];
      persist.state = {
        directories = [
          "/var/lib/nixos"
          "/var/lib/systemd"
        ]
        ++ lib.optionals config.services.mysql.enable [
          config.services.mysql.dataDir
        ]
        ++ lib.optionals config.services.postgresql.enable [
          "/var/lib/postgresql"
        ];
        files = [
          "/etc/machine-id"
        ];
      };
    };
}
