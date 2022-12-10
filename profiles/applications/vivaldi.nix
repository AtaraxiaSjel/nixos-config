{ pkgs, ... }: {
#   defaultApplications.browser = {
#     cmd = "${pkgs.vivaldi}/bin/vivaldi";
#     desktop = "vivaldi";
#   };

  home-manager.users.${config.mainuser} = {
    home.packages = with pkgs; [
      ((vivaldi.overrideAttrs (oldAttrs: rec {
          buildInputs = oldAttrs.buildInputs ++ [ pkgs.libglvnd pkgs.pipewire pkgs.wayland ];
          # --enable-features=UseOzonePlatform,UseSkiaRenderer,Vulkan --ozone-platform=wayland
          postInstall = ''
            substituteInPlace "$out"/bin/vivaldi \
              --replace 'vivaldi-wrapped"  "$@"' 'vivaldi-wrapped" --ignore-gpu-blocklist --enable-gpu-rasterization \
              --enable-zero-copy --use-gl=desktop "$@"'
          '';
        })).override { proprietaryCodecs = true; })
    ];

    xdg.configFile."vivaldi/css/custom.css".source = pkgs.writeText "custom.css" ''
      #header {
          min-height: 0;
          z-index: auto;
      }
      .vivaldi, .window-buttongroup {
          z-index: 999;
      }
      .vivaldi {
          position: relative !important;
          top: 3px !important;
      }
      .topmenu {
          position: absolute;
      }
      .topmenu>nav {
          left: -28px;
          top: 4px;
      }
      .horizontal-menu .toolbar.toolbar-addressbar {
          padding: 0 150px 0 269px !important;
      }
      .toolbar.toolbar-addressbar {
          padding: 0 150px 0 50px !important;
          height: 36px;
      }
      .bookmark-bar {
          margin-bottom: 0;
      }
      .window-buttongroup {
          display: none !important;
      }
      .UrlBar {
          margin-left: 34px;
      }
    '';
  };
}