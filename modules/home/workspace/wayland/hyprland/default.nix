{
  config,
  lib,
  pkgs,
  osConfig ? null,
  ...
}:
let
  inherit (lib)
    concatMapAttrsStringSep
    concatMapStringsSep
    getExe
    mkEnableOption
    mkIf
    replaceStrings
    ;

  cfg = config.ataraxia.wayland.hyprland;

  apps = config.defaultApplications;
  useNixosHyprland = osConfig != null && osConfig.programs.hyprland.enable;
  useWithUWSM = osConfig != null && osConfig.programs.hyprland.withUWSM;

  mpvExe = getExe config.programs.mpv.package;
  yt-mpv = pkgs.writeShellScript "yt-mpv" ''
    if [[ "$1" != "--no-video" ]]; then
      ${getExe pkgs.libnotify} -t 3000 --icon=video-television "Playing Video" "$(${pkgs.wl-clipboard}/bin/wl-paste)"
      ${mpvExe} --fs "$(${pkgs.wl-clipboard}/bin/wl-paste)"
    else
      ${getExe pkgs.libnotify}/bin/notify-send -t 3000 --icon=video-television "Playing Audio" "$(${pkgs.wl-clipboard}/bin/wl-paste)"
      ${apps.term.cmd} -e ${mpvExe} --no-video "$(${pkgs.wl-clipboard}/bin/wl-paste)"
    fi
  '';

  # screen-ocr = pkgs.writeShellScript "screen-ocr" ''
  #   grim -g "$(slurp)" - | ${getExe pkgs.tesseract} -l eng - - | wl-copy
  # '';

  # config-dir =
  #   if config.persist.enable then
  #     "${config.persist.persistRoot}/home/${config.home.username}/nixos-config/modules/home/workspace/wayland/hyprland"
  #   else
  #     "${config.home.homeDirectory}/modules/home/workspace/wayland/hyprland";

  nix-vars = pkgs.writeText "nix_vars.lua" ''
    return {
      ${
        (concatMapAttrsStringSep "\n  " (n: v: "${replaceStrings [ "-" ] [ "_" ] n} = \"${v.cmd}\",") apps)
      }
      mpv = "${mpvExe}",
      yt_mpv = "${yt-mpv}"
    }
  '';

  autostart = pkgs.writeText "autostart.lua" ''
    hl.on("hyprland.start", function()
        ${concatMapStringsSep "\n    " (x: "hl.exec_cmd(\"uwsm app -t service -- ${x}\")") (
          config.startupApplications
          ++ [
            "${pkgs.mate-polkit}/libexec/polkit-mate-authentication-agent-1"
          ]
        )}
    end)
  '';
in
{
  options.ataraxia.wayland.hyprland = {
    enable = mkEnableOption "Enable hyprland";
  };

  config = mkIf cfg.enable {
    # xdg.configFile."hypr/hyprland.lua".source =
    #   config.lib.file.mkOutOfStoreSymlink "${config-dir}/hyprland.lua";
    xdg.configFile."hypr/hyprland.lua".source = ./hyprland.lua;
    xdg.configFile."hypr/autostart.lua".source = autostart;
    xdg.configFile."hypr/nix_vars.lua".source = nix-vars;

    home.packages = with pkgs; [
      grim
      libnotify
      mpris-ctl
      pamixer
      pavucontrol
      satty
      slurp
      wl-clipboard
      xdg-user-dirs
    ];

    wayland.windowManager.hyprland = {
      configType = "lua";

      enable = true;
      package = mkIf useNixosHyprland null;
      portalPackage = mkIf useNixosHyprland null;
      systemd.enable = !useWithUWSM;
      systemd.variables = [ "--all" ];
      xwayland.enable = true;
    };

    persist.state.directories = [
      ".config/hypr"
      ".local/share/hyprland"
    ];
  };
}
