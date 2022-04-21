{ config, pkgs, lib, ... }:
with lib;
let
  thm = config.lib.base16.theme;
  fonts = config.lib.base16.theme.fonts;
  profileName = "alukard";
  profilePath = ".mozilla/firefox/${profileName}";
  mkUserJs = { prefs ? {}, extraPrefs ? "" }: ''
    ${extraPrefs}

    ${concatStrings (mapAttrsToList (name: value: ''
      user_pref("${name}", ${builtins.toJSON value});
    '') prefs)}
  '';

  firefox-kpoxa = pkgs.writeShellScriptBin "firefox-kpoxa" ''
    ${pkgs.firefox-wayland}/bin/firefox -profile /home/alukard/.mozilla/firefox/kpoxa
  '';
in {
  environment.sessionVariables = {
    MOZ_USE_XINPUT2 = "1";
    MOZ_DBUS_REMOTE = "1";
  };
  # programs.browserpass.enable = true;

  defaultApplications.browser = {
    cmd = "${pkgs.firefox-wayland}/bin/firefox";
    desktop = "firefox";
  };

  home-manager.users.alukard = {
    home.packages = [ firefox-kpoxa ];
    # programs.browserpass = {
    #   enable = true;
    #   browsers = [ "firefox" ];
    # };
    wayland.windowManager.sway.config = {
      window.commands = [
        {
          criteria = { title = "Firefox — Sharing Indicator"; };
          command = "floating enable";
        }
        {
          criteria = { title = "Firefox — Sharing Indicator"; };
          command = "no_focus";
        }
        {
          criteria = { title = "Firefox — Sharing Indicator"; };
          command = "resize set 0 0";
        }
        {
          criteria = { title = "Firefox — Sharing Indicator"; };
          command = "move absolute position 10 10";
        }
      ];
    };

    programs.firefox = {
      enable = true;
      package = pkgs.firefox-wayland;
      profiles = {
        alukard = {
          id = 0;
          userChrome = ''
            #TabsToolbar {
              visibility: collapse;
            }
            toolbar#nav-bar, nav-bar-customization-target {
              background: ${thm.base00-hex} !important;
            }
            @-moz-document url("about:newtab") {
              * { background-color: ${thm.base00-hex}  !important; }
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
              "browser.startup.homepage" = "https://startpage.ataraxiadev.com";
              "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
              "browser.search.suggest.enabled" = true;
              "ui.context_menus.after_mouseup" = true;

              "font.name.monospace.x-western" = "${fonts.mono.family}";
              "font.name.sans-serif.x-western" = "${fonts.main.family}";
              "font.name.serif.x-western" = "${fonts.serif.family}";
              "browser.display.background_color" = thm.base00-hex;
              "browser.display.foreground_color" = thm.base05-hex;
              # "browser.display.document_color_use" = 2;
              "browser.anchor_color" = thm.base0D-hex;
              "browser.visited_color" = thm.base0C-hex;
              "browser.display.use_document_fonts" = true;
              "pdfjs.disabled" = true;

              "media.eme.enabled" = true;

              "experiments.activeExperiment" = false;
              "experiments.enabled" = false;
              "experiments.supported" = false;
              "network.allow-experiments" = false;
            };
            extraPrefs = "${fileContents "${pkgs.arkenfox-userjs}/share/user-js/profiles/user.js"}";
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
              "browser.startup.homepage" = "https://startpage.ataraxiadev.com";
              "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
              "browser.search.suggest.enabled" = true;
              "browser.urlbar.suggest.searches" = true;
              "ui.context_menus.after_mouseup" = true;
              "keyword.enabled" = true;
              "media.eme.enabled" = true;

              "browser.startup.page" = 3;
              "network.cookie.lifetimePolicy" = 0;
              "browser.sessionstore.privacy_level" = 0;
              "privacy.clearOnShutdown.history" = false;
              "privacy.cpd.history" = false;

              "font.name.monospace.x-western" = "${fonts.mono.family}";
              "font.name.sans-serif.x-western" = "${fonts.main.family}";
              "font.name.serif.x-western" = "${fonts.serif.family}";
              "browser.display.background_color" = thm.base00-hex;
              "browser.display.foreground_color" = thm.base05-hex;
              "browser.anchor_color" = thm.base0D-hex;
              "browser.visited_color" = thm.base0C-hex;
              "browser.display.use_document_fonts" = true;

              "experiments.activeExperiment" = false;
              "experiments.enabled" = false;
              "experiments.supported" = false;
              "network.allow-experiments" = false;
            };
            extraPrefs = "${fileContents "${pkgs.arkenfox-userjs}/share/user-js/profiles/user.js"}";
          };
        };
      };
      # extensions = with pkgs.nur.repos.rycee.firefox-addons; [
      #   # add-custom-search-engine
      #   adsum-notabs
      #   # auto-tab-discard
      #   bitwarden
      #   # browserpass
      #   darkreader
      #   gesturefy
      #   libredirect
      #   markdownload
      #   refined-github
      #   # rust-search-extension
      #   search-by-image
      #   # search-engines-helper
      #   skip-redirect
      #   stylus
      #   tab-session-manager
      #   # tampermonkey
      #   terms-of-service-didnt-read
      #   ublock-origin
      # ];
    };
  };
}
