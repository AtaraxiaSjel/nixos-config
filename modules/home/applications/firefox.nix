{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    concatStrings
    fileContents
    getExe
    mapAttrsToList
    mkEnableOption
    mkIf
    ;
  inherit (config.theme) colors fonts;

  cfg = config.ataraxia.programs.firefox;

  homeDir = config.home.homeDirectory;
  mkUserJs =
    {
      prefs ? { },
      extraPrefs ? "",
    }:
    ''
      ${extraPrefs}

      ${concatStrings (
        mapAttrsToList (name: value: ''
          user_pref("${name}", ${builtins.toJSON value});
        '') prefs
      )}
    '';

  finalPackage = config.programs.firefox.finalPackage;
  firefox-kpoxa = pkgs.writeShellScriptBin "firefox-kpoxa" ''
    ${getExe finalPackage} -profile ${homeDir}/.mozilla/firefox/kpoxa
  '';
  username = config.home.username;
in
{
  options.ataraxia.programs.firefox = {
    enable = mkEnableOption "Enable firefox program";
  };

  config = mkIf cfg.enable {
    dbus.packages = [ finalPackage ];
    home.packages = [ firefox-kpoxa ];
    home.sessionVariables = {
      MOZ_USE_XINPUT2 = "1";
      MOZ_DBUS_REMOTE = "1";
    };

    defaultApplications.browser = {
      cmd = getExe finalPackage;
      desktop = "firefox";
    };

    programs.firefox = {
      enable = true;
      package = pkgs.firefox.override {
        # Mailvelope GnuPG integration
        nativeMessagingHosts = [
          (pkgs.writeTextDir "lib/mozilla/native-messaging-hosts/gpgmejson.json" ''
            {
              "name": "gpgmejson",
              "description": "JavaScript binding for GnuPG",
              "path": "${pkgs.gpgme.dev}/bin/gpgme-json",
              "type": "stdio",
              "allowed_extensions": ["jid1-AQqSMBYb0a8ADg@jetpack"]
            }
          '')
        ];
      };
      profiles = {
        ${username} = {
          id = 0;
          userChrome = ''
            #TabsToolbar {
              visibility: collapse;
            }
            toolbar#nav-bar, nav-bar-customization-target {
              background: ${colors.color0} !important;
            }
            @-moz-document url("about:newtab") {
              * { background-color: ${colors.color0}  !important; }
            }
          '';
          userContent = ''
            .scroll-styled-h, .scroll-styled-v, html {
              scrollbar-color: #495460 rgba(255, 255, 255, .0);
              scrollbar-width: thin;
            }
          '';
          extraConfig = mkUserJs {
            prefs = {
              "network.http.referer.XOriginPolicy" = 0;
              "signon.rememberSignons" = false;
              "browser.quitShortcut.disabled" = true;
              "general.autoScroll" = true;
              "extensions.pocket.enabled" = false;
              "browser.startup.page" = 1;
              "browser.startup.homepage" = "https://ataraxiadev.com";
              "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
              "browser.search.suggest.enabled" = true;
              "ui.context_menus.after_mouseup" = true;

              "font.name.monospace.x-western" = fonts.mono.family;
              "font.name.sans-serif.x-western" = fonts.sans.family;
              "font.name.serif.x-western" = fonts.serif.family;
              "browser.display.background_color" = colors.color0;
              "browser.display.foreground_color" = colors.color5;
              "browser.anchor_color" = colors.color13;
              "browser.visited_color" = colors.color12;
              "browser.display.use_document_fonts" = true;
              "pdfjs.disabled" = false;

              "media.eme.enabled" = true;
              "media.ffmpeg.vaapi.enabled" = true;

              "experiments.activeExperiment" = false;
              "experiments.enabled" = false;
              "experiments.supported" = false;
              "network.allow-experiments" = false;

              "network.protocol-handler.external.element" = false;
            };
            extraPrefs = "${fileContents "${pkgs.arkenfox-userjs}/share/user.js/user.js"}";
          };
        };
        kpoxa = {
          id = 1;
          userContent = ''
            .scroll-styled-h, .scroll-styled-v, html {
              scrollbar-color: #495460 rgba(255, 255, 255, .0);
              scrollbar-width: thin;
            }
          '';
          extraConfig = mkUserJs {
            prefs = {
              "network.http.referer.XOriginPolicy" = 0;
              "signon.rememberSignons" = false;
              "general.autoScroll" = true;
              "extensions.pocket.enabled" = false;
              "browser.startup.homepage" = "https://ataraxiadev.com";
              "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
              "browser.search.suggest.enabled" = true;
              "browser.urlbar.suggest.searches" = true;
              "ui.context_menus.after_mouseup" = true;
              "keyword.enabled" = true;
              "media.eme.enabled" = true;

              "browser.startup.page" = 3;
              "browser.sessionstore.privacy_level" = 0;
              "privacy.clearOnShutdown.history" = false;
              "privacy.clearOnShutdown.cookies" = false;
              "privacy.cpd.history" = false;

              "font.name.monospace.x-western" = fonts.mono.family;
              "font.name.sans-serif.x-western" = fonts.sans.family;
              "font.name.serif.x-western" = fonts.serif.family;
              "browser.display.background_color" = colors.color0;
              "browser.display.foreground_color" = colors.color5;
              "browser.anchor_color" = colors.color13;
              "browser.visited_color" = colors.color12;
              "browser.display.use_document_fonts" = true;

              "experiments.activeExperiment" = false;
              "experiments.enabled" = false;
              "experiments.supported" = false;
              "network.allow-experiments" = false;

              "network.protocol-handler.external.element" = false;
            };
            extraPrefs = "${fileContents "${pkgs.arkenfox-userjs}/share/user.js/user.js"}";
          };
        };
      };
    };

    persist.state.directories = [
      # ".mozilla/firefox/${username}"
      # ".mozilla/firefox/kpoxa"
      ".mozilla/firefox"
    ];
  };
}
