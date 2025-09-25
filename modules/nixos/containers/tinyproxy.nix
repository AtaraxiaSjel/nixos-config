{
  config,
  lib,
  secretsDir,
  inputs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.ataraxia.containers.tinyproxy;
in
{
  options.ataraxia.containers.tinyproxy = {
    enable = mkEnableOption "Enable tinyproxy nixos-container";
  };

  config = mkIf cfg.enable {
    sops.secrets.tinyproxy-singbox = {
      sopsFile = secretsDir + /proxy.yaml;
      restartUnits = [ "container@tinyproxy.service" ];
      mode = "0600";
    };
    containers.tinyproxy = {
      # extraFlags = [ "-U" ];
      autoStart = true;
      ephemeral = true;
      privateNetwork = true;
      hostBridge = "br0";
      localAddress = "10.10.10.6/24";
      bindMounts."/tmp/sing-box.json".hostPath = config.sops.secrets.tinyproxy-singbox.path;
      config =
        { pkgs, ... }:
        {
          nixpkgs.overlays = [
            (_final: _prev: {
              sing-box = inputs.ataraxiasjel-nur.packages.${pkgs.hostPlatform.system}.sing-box-extended;
            })
          ];
          environment.systemPackages = with pkgs; [
            dnsutils
            kitty.terminfo
            sing-box
          ];
          systemd.packages = with pkgs; [ sing-box ];
          systemd.services.sing-box = {
            preStart = ''
              umask 0007
              mkdir -p ''${RUNTIME_DIRECTORY}
              cp /tmp/sing-box.json ''${RUNTIME_DIRECTORY}/config.json
            '';
            serviceConfig = {
              StateDirectory = "sing-box";
              StateDirectoryMode = "0700";
              RuntimeDirectory = "sing-box";
              RuntimeDirectoryMode = "0700";
              ExecStart = [
                ""
                "${lib.getExe pkgs.sing-box} -D \${STATE_DIRECTORY} -C \${RUNTIME_DIRECTORY} run"
              ];
            };
            wantedBy = [ "multi-user.target" ];
          };
          networking = {
            dhcpcd.denyInterfaces = [ "singtun0" ];
            defaultGateway = "10.10.10.1";
            hostName = "tinyproxy-node";
            nameservers = [
              "10.10.10.9"
              "10.10.10.1"
            ];
            useHostResolvConf = false;
            firewall = {
              enable = true;
              allowedTCPPorts = [
                8888
                8889
              ];
              rejectPackets = false;
            };
          };
          system.stateVersion = "25.05";
        };
    };
  };
}
