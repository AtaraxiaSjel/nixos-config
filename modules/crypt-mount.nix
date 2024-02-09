{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  options.services.cryptmount = mkOption {
    type = types.attrsOf (
      types.submodule (
        { name, ... }:
        {
          options = {
            cryptname = mkOption {
              type = types.str;
              default = name;
            };
            passwordFile = mkOption { type = types.str; };
            what = mkOption { type = types.str; };
            where = mkOption { type = types.str; };
            fsType = mkOption {
              type = with types; nullOr str;
              default = null;
            };
            cryptType = mkOption {
              type = types.enum [
                "luks"
                "luks1"
                "luks2"
                "plain"
                "loopaes"
                "tcrypt"
                "bitlk"
              ];
              default = "luks";
            };
            mountOptions = mkOption {
              type = with types; listOf str;
              default = [ ];
            };
          };
        }
      )
    );
    default = { };
  };
  config = mkIf (config.services.cryptmount != { }) {
    systemd.services =
      mapAttrs'
        (
          name: cfg:
          nameValuePair "cryptmount-${name}" ({
            wantedBy = [ "multi-user.target" ];
            path = [ pkgs.cryptsetup ];
            serviceConfig =
              let
                mount-type = if (cfg.fsType != null) then "-t ${cfg.fsType}" else "";
                opts =
                  if (cfg.mountOptions != [ ]) then "-o ${strings.concatStringsSep "," cfg.mountOptions}" else "";
              in
              {
                Type = "oneshot";
                TimeoutStartSec = "infinity";
                RemainAfterExit = true;
                ExecStart = pkgs.writeShellScript "storage-decrypt-${name}" ''
                  set -euo pipefail
                  mkdir -p ${cfg.where}
                  cat ${cfg.passwordFile} | cryptsetup open ${cfg.what} ${cfg.cryptname} - --type ${cfg.cryptType}
                  /run/wrappers/bin/mount ${mount-type} ${opts} /dev/mapper/${cfg.cryptname} ${cfg.where}
                '';
                ExecStop = pkgs.writeShellScript "storage-decrypt-stop-${name}" ''
                  /run/wrappers/bin/umount -R ${cfg.where}
                  cryptsetup close ${cfg.cryptname}
                '';
              };
          })
        )
        config.services.cryptmount;
  };
}
