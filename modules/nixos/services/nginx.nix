{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkOption;
  inherit (lib.types) attrs;

  cfg = config.ataraxia.services.nginx;
in
{
  options.ataraxia.services.nginx = {
    enable = mkEnableOption "Enable nginx service";
    defaultSettings = mkOption {
      type = attrs;
      default = { };
      description = ''
        Default settings to append to virtualHosts. Does not apllied automatically.
        Usage example: `your-host = recursiveUpdate defaultSettings { };`
      '';
    };
    tinyauthSettings = mkOption {
      type = attrs;
      default = { };
      description = ''
        Tinyauth settings to append to virtualHosts. Does not apllied automatically.
      '';
    };
    # extraConfig = mkOption {
    #   type = str;
    #   default = "";
    #   description = ''
    #     Default settings to append to extraConfig of virtual host's location. Does not apllied automatically.
    #     Usage example: `extraConfig = recursiveUpdate extraConfig "";`
    #   '';
    # };
  };

  config = mkIf cfg.enable {
    services.nginx = {
      enable = true;
      package = pkgs.nginxQuic;
      recommendedBrotliSettings = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      recommendedUwsgiSettings = true;
      recommendedZstdSettings = true;
      clientMaxBodySize = "250m";
      commonHttpConfig = ''
        proxy_hide_header X-Frame-Options;
        proxy_headers_hash_max_size 1024;
        proxy_headers_hash_bucket_size 128;
      '';
    };

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
    networking.firewall.allowedUDPPorts = [
      80
      443
    ];
  };
}
