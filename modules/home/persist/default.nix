{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption mkEnableOption mkIf;
  inherit (lib.types) listOf path str;
  cfg = config.persist;
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

  config = mkIf cfg.enable {
    # Persist by default
    persist.cache.directories = [ ".cache" ];
    persist.state = {
      directories = [ ".local/share/nix" ];
    };
  };
}
