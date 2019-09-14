{ pkgs, config, lib, ... }:
with import ../../../support.nix { inherit pkgs config lib; };
let scripts = import ./scripts pkgs config;
in {
  home-manager.users.alukard.xsession.windowManager.i3.extraConfig = ''
    bar {
      id top
      font pango:Material Icons 11, Roboto Mono 11
      mode dock
      hidden_state hide
      position top
      status_command ${pkgs.i3blocks}/bin/i3blocks
      workspace_buttons yes
      strip_workspace_numbers no
      tray_output none
      colors {
        background ${config.themes.colors.bg}
        statusline ${config.themes.colors.fg}
        separator ${config.themes.colors.alt}
        focused_workspace ${config.themes.colors.bg} ${config.themes.colors.bg} ${config.themes.colors.blue}
        active_workspace ${config.themes.colors.bg} ${config.themes.colors.bg} ${config.themes.colors.green}
        inactive_workspace ${config.themes.colors.bg} ${config.themes.colors.bg} ${config.themes.colors.fg}
        urgent_workspace ${config.themes.colors.bg} ${config.themes.colors.bg} ${config.themes.colors.orange}
        binding_mode ${config.themes.colors.bg} ${config.themes.colors.bg} ${config.themes.colors.yellow}
      }
    }
  '';

  home-manager.users.alukard.xdg.configFile."i3blocks/config".text = ''
    interval=60
    markup=pango
  '' + genIni {
    a_email = if !isNull config.secrets.gmail or null then {
      command = scripts.email;
    } else
      { };
    b_weather = {
      command = scripts.weather;
      interval = 600;
    };
    d_sound = {
      command = scripts.sound;
      interval = 1;
    };
    # e_music = {
    #   command = scripts.music;
    #   interval = 1;
    # };
    f_battery = pkgs.stdenv.lib.optionalAttrs config.deviceSpecific.isLaptop {
      command = scripts.battery;
    };
    g_brightness = pkgs.stdenv.lib.optionalAttrs config.deviceSpecific.isLaptop {
      command = scripts.brightness;
      interval = 1;
    };
    h_wireless = pkgs.stdenv.lib.optionalAttrs config.networking.wireless.enable {
      command = scripts.wireless;
    };
    # i_network = {
    #   command = scripts.network;
    # };
    j_cpuload = {
      command = ''
        echo '<span font="Material Icons 11">cached</span>' $(top -b -n1 -p 1 | fgrep "Cpu(s)" | tail -1 | awk -F'id,' -v prefix="$prefix" '{ split($1, vs, ","); v=vs[length(vs)]; sub("%", "", v); printf "%s%.1f%%\n", prefix, 100 - v }')
      '';
      interval = 3;
    };
    k_cpufreq = {
      command = ''
        echo '<span font="Material Icons 11">flash_on</span>' $(${pkgs.bc}/bin/bc <<< "$(lscpu | grep "MHz" | awk '{print $3}')/1") MHz
      '';
      interval = 1;
    };
    # l_temperature = {
    #   command = scripts.temperature;
    # };
    m_free = {
      command = ''
        echo '<span font="Material Icons 11">location_searching</span>' $(${pkgs.bc}/bin/bc <<< `free | tail -2 | head -1 | awk '{print "scale=2; "$7"/1048576"}'`)GiB
      '';
      # command = scripts.free;
    };
    n_df = {
      command = ''
        echo '<span font="Material Icons 11"></span>' $(sudo btrfs fi usage / | grep "Free" | awk '{print $3}')
      '';
    };
    o_date = {
      command = "${pkgs.coreutils}/bin/date +'<span font=\"Material Icons 11\"></span> %a %y-%m-%d'";
      interval = 10;
    };
    p_time = {
      command = "${pkgs.coreutils}/bin/date +'<span font=\"Material Icons 11\"></span> %T'";
      interval = 1;
    };
  };
}
