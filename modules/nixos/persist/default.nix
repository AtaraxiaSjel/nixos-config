{
  config,
  lib,
  inputs,
  ...
}:
let
  inherit (lib)
    escapeShellArg
    hasPrefix
    hasSuffix
    mkEnableOption
    mkDefault
    mkIf
    mkOption
    optionalString
    recursiveUpdate
    unique
    ;
  inherit (lib.types) listOf path str;
  inherit (builtins) any concatMap filter;
  cfg = config.persist;

  btrfs = config.ataraxia.filesystems.btrfs.mountpoints;
  zfs = config.ataraxia.filesystems.zfs.mountpoints;
  mountpoints = map (x: "${x}${optionalString (!(hasSuffix "/" x)) "/"}") (unique (btrfs ++ zfs));

  subtractListsPrefix = a: filter (dir: !(any (pref: hasPrefix pref dir) a));
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
        hideMounts = true;
        directories = filteredDirs;
        files = allFiles;
        # users = usersFlatten;
      };

      programs.fuse.userAllowOther = mkDefault true;

      systemd.services.persist-cache-cleanup = mkIf cfg.cache.clean.enable {
        description = "Cleaning up cache files and directories";
        script = ''
          ${builtins.concatStringsSep "\n" (map (x: "rm ${escapeShellArg x}") cfg.cache.files)}

          ${builtins.concatStringsSep "\n" (map (x: "rm -rf ${escapeShellArg x}") cfg.cache.directories)}
        '';
        startAt = cfg.cache.clean.dates;
      };

      fileSystems.${cfg.persistRoot}.neededForBoot = true;
      # Persist by default
      persist.cache.directories = [
        "/var/cache"
      ];
      persist.state = {
        directories =
          [
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
          "/etc/ssh/ssh_host_ed25519_key"
          "/etc/ssh/ssh_host_ed25519_key.pub"
          "/etc/ssh/ssh_host_rsa_key"
          "/etc/ssh/ssh_host_rsa_key.pub"
        ];
      };
    };
}
