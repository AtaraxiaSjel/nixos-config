{ pkgs, config, lib, ... }:
let
  scripts = import ./scripts pkgs config;
  thm = config.lib.base16.theme;
in {
  home-manager.users.alukard = {
    # xsession.windowManager.i3.config.bars = [{
    wayland.windowManager.sway.config.bars = [{
      id = "default";
      position = "top";
      statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ~/.config/i3status-rust/config-top.toml";
      workspaceNumbers = false;
      fonts = {
        names = [ "${thm.fonts.powerline.family}" "${thm.fonts.icon.family}" "${thm.fonts.iconFallback.family}" ];
        style = "Regular";
        size = thm.fontSizes.micro.float;
      };
      colors = let
        default = {
          background = "#${thm.base00-hex}";
          border = "#${thm.base00-hex}";
        };
      in {
        background = "#${thm.base00-hex}";
        statusline = "#${thm.base05-hex}";
        separator = "#${thm.base02-hex}";
        focusedWorkspace = default // { text = "#${thm.base08-hex}"; };
        activeWorkspace = default // { text = "#${thm.base0B-hex}"; };
        inactiveWorkspace = default // { text = "#${thm.base05-hex}"; };
        urgentWorkspace = default // { text = "#${thm.base09-hex}"; };
        bindingMode = default // { text = "#${thm.base0A-hex}"; };
      };
    }];

    programs.i3status-rust = {
      enable = true;
      bars.top = {
        settings = {
          theme = {
            name = "solarized-dark";
            overrides = {
              idle_bg = "#${thm.base00-hex}";
              idle_fg = "#${thm.base05-hex}";
              info_bg = "#${thm.base0C-hex}";
              info_fg = "#${thm.base00-hex}";
              good_bg = "#${thm.base0B-hex}";
              good_fg = "#${thm.base00-hex}";
              warning_bg = "#${thm.base0A-hex}";
              warning_fg = "#${thm.base00-hex}";
              critical_bg = "#${thm.base08-hex}";
              critical_fg = "#${thm.base00-hex}";
            };
          };
          icons = {
            name = "awesome5";
            overrides = {
              backlight_empty = " 🌑 ";
              backlight_full = " 🌕 ";
              backlight_partial1 = " 🌘 ";
              backlight_partial2 = " 🌗 ";
              backlight_partial3 = " 🌖 ";
              cpu = "";
              net_wired = "";
              net_wireless = "";
            };
          };
        };
        blocks = [
          {
            block = "net";
            device = if config.device == "Dell-Laptop" then
              "wlo1"
            else if config.device == "AMD-Workstation" then
              "enp9s0"
            else "";
          }
        ] ++ lib.optionals config.deviceSpecific.isLaptop [
          {
            block = "battery";
            interval = 10;
            format = "{percentage} {time}";
          }
          {
            block = "backlight";
          }
        ] ++ [
          {
            block = "custom";
            command = "${scripts.weather}";
            interval = 600;
          }
          {
            block = "sound";
            driver = "auto";
          }
          {
            block = "temperature";
            # collapsed = false;
            chip = if config.device == "Dell-Laptop" then
              "*-isa-*"
            else if config.device == "AMD-Workstation" then
              "*-pci-*"
            else "*-pci-*";
          }
          {
            block = "cpu";
            interval = 1;
            format = "{utilization} {frequency}";
          }
          {
            block = "custom";
            command = "${scripts.df}";
            interval = 60;
          }
          {
            block = "memory";
            display_type = "memory";
            format_mem = "{mem_avail;G}";
            format_swap = "{swap_free;G}";
          }
          {
            block = "time";
            interval = 1;
            format = "%a %Y/%m/%d %T";
          }
        ];
      };
    };
  };
}
