{ pkgs, config, lib, ... }: {
  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
    appendHttpConfig = "charset utf-8;";
    virtualHosts = let
      default = {
        forceSSL = false;
        enableACME = false;
      };
    in {
      "ataraxiadev.com" = {
        default = true;
        locations."/" = {
          root = "/var/lib/ataraxiadev.com";
          # index = "index.txt";
        };
        locations."/.well-known" = {
          proxyPass = "http://localhost:13748";
        };
        locations."/_matrix" = {
          proxyPass = "http://localhost:13748";
        };
      } // default;
      "matrix.ataraxiadev.com" = {
        locations."/" = {
          proxyPass = "http://localhost:13748";
        };
      } // default;
    };
  };
  # security.acme = {
  #   email = "ataraxiadev@ataraxiadev.com";
  #   acceptTerms = true;
  # };
}