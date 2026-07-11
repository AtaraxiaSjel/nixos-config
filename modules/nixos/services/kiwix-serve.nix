{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    recursiveUpdate
    mkEnableOption
    mkIf
    mkOption
    ;
  inherit (lib.types) bool;
  inherit (config.ataraxia.lists) ports;

  cfg = config.ataraxia.services.kiwix-serve;
  nginx = config.ataraxia.services.nginx;
  domain = "wiki.ataraxiadev.com";
in
{

  options.ataraxia.services.kiwix-serve = {
    enable = mkEnableOption "Enable kiwix-serve service";
    nginxHost = mkOption {
      type = bool;
      default = config.ataraxia.services.nginx.enable;
      description = "Enable nginx vHost integration";
    };
  };

  config = mkIf cfg.enable {
    services.kiwix-serve = {
      enable = true;
      port = ports.kiwix.int;
      openFirewall = false;
      # libraryPath = "/srv/zim/kiwix.xml";
      library = { 
        wikipedia-en = "/srv/zim/wikipedia_en_all_maxi_2026-02.zim";
        wikipedia-ru = "/srv/zim/wikipedia_ru_all_maxi_2026-02.zim";
        wikibooks-en = "/srv/zim/wikibooks_en_all_maxi_2026-04.zim";
        wikibooks-ru = "/srv/zim/wikibooks_ru_all_maxi_2026-04.zim";
      };
    };

    services.nginx.virtualHosts = mkIf cfg.nginxHost {
      ${domain} = recursiveUpdate nginx.tinyauthSettings {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${ports.kiwix.str}";
        };
      };
    };
  };
}
