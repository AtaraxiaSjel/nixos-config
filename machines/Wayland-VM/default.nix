{ modulesPath, inputs, lib, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    "${modulesPath}/profiles/qemu-guest.nix"
    "${modulesPath}/profiles/minimal.nix"
    ./system-path.nix
    ./qemu-vm.nix
  ];
  disabledModules = [ "config/system-path.nix" ];

  options = {
    device = lib.mkOption { type = lib.types.str; };
  };

  config = {
    # system.nssModules = lib.mkForce [ ];
    services.udisks2.enable = false;
    # services.nscd.enable = false;

    boot = {
      loader.systemd-boot.enable = true;

      kernelPackages = pkgs.linuxPackages_zen;

      kernelParams = [
        "zswap.enabled=0" "quiet" "scsi_mod.use_blk_mq=1" "modeset" "nofb"
        "pti=off"
        "spectre_v2=off"
        "kvm.ignore_msrs=1"
      ];
    };

    hardware.opengl.enable = true;

    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 60;
      numDevices = 1;
    };

    networking.firewall.enable = false;
    networking.wireless.enable = false;
    networking.networkmanager.enable = false;
    networking.hostName = "Wayland-VM";

    users.mutableUsers = false;
    users.users.alukard = {
      isNormalUser = true;
      extraGroups = [ "wheel" "video" "input" ];
      uid = 1000;
      hashedPassword = "$6$6n2Grnv11bvhOj8S$cFkS4P/8K5qOgjDRfhvwbWLogcCg0AAQRA4FjzmgthIeKohORtQYif5XvprE7mJfbApo6fbMr0o3ld8pViWx3.";
    };

    nix = {
      nixPath = lib.mkForce [ "self=/etc/self/compat" "nixpkgs=/etc/nixpkgs" ];
      registry.self.flake = inputs.self;
      registry.nixpkgs.flake = inputs.nixpkgs;
      optimise.automatic = true;
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
      settings.auto-optimise-store = false;
    };

    environment.etc.nixpkgs.source = inputs.nixpkgs;
    environment.etc.self.source = inputs.self;

    environment.systemPackages = [
      pkgs.labwc.overrideAttrs (old: {
        mesonFlags = [ "-Dxwayland=disabled" ];
      })
      pkgs.nano
      pkgs.foot
      pkgs.gnused
      pkgs.ncftp
    ];

    environment.sessionVariables = {
      LIBSEAT_BACKEND = "logind";
    };

    i18n.defaultLocale = "en_GB.UTF-8";
    console.font = "cyr-sun16";
    console.keyMap = "ruwin_cplk-UTF-8";

    fonts = {
      fonts = [ pkgs.ibm-plex ];
      fontconfig = {
        enable = true;
        defaultFonts = {
          monospace = [ "IBM Plex Mono 12" ];
          sansSerif = [ "IBM Plex Sans 12" ];
          serif = [ "IBM Plex Serif 12" ];
        };
      };
      enableDefaultFonts = false;
    };

    environment.noXlibs = lib.mkForce false;

    security.polkit.enable = true;

    system.stateVersion = "22.11";

    services.getty.autologinUser = "alukard";

    environment.etc."gbinder.d/waydroid.conf".source = let
        waydroidGbinderConf = pkgs.writeText "waydroid.conf" ''
          [General]
          ApiLevel = 29
        '';
      in lib.mkForce waydroidGbinderConf;
    virtualisation.waydroid.enable = true;

    environment.loginShellInit = lib.mkAfter ''
      [[ "$(tty)" == /dev/tty1 ]] && {
        labwc -s foot
      }
    '';

    system.userActivationScripts.linktosharedfolder.text = let
      foot = pkgs.writeText "foot.ini" ''
        font=IBM Plex Mono:size=12
      '';
    in ''
      if [[ ! -d "$HOME/.config/foot" ]]; then
        mkdir -p $HOME/.config/foot
      fi
      if [[ -h "$HOME/.config/foot/foot.ini" ]]; then
        rm -f "$HOME/.config/foot/foot.ini"
      fi
      ln -s "${foot}" "$HOME/.config/foot/foot.ini"
    '';

    environment.etc."xdg/labwc/environment".text = ''
      XDG_CURRENT_DESKTOP=wlroots
      XKB_DEFAULT_LAYOUT=us,ru
      XKB_DEFAULT_OPTIONS=grp:win_space_toggle
    '';

    environment.etc."xdg/labwc/menu.xml".text = ''
      <?xml version="1.0" encoding="UTF-8"?>

      <openbox_menu>

      <menu id="client-menu" label="">
        <item label="Minimize">
          <action name="Iconify" />
        </item>
        <item label="Maximize">
          <action name="ToggleMaximize" />
        </item>
        <item label="Fullscreen">
          <action name="ToggleFullscreen" />
        </item>
        <item label="Decorations">
          <action name="ToggleDecorations" />
        </item>
        <item label="AlwaysOnTop">
          <action name="ToggleAlwaysOnTop" />
        </item>
        <item label="Close">
          <action name="Close" />
        </item>
      </menu>

      <menu id="root-menu" label="">
        <item label="Terminal">
          <action name="Execute"><command>foot</command></action>
        </item>
        <item label="Reconfigure">
          <action name="Reconfigure"></action>
        </item>
        <item label="Exit">
          <action name="Exit"></action>
        </item>
        <item label="Poweroff">
          <action name="Execute"><command>systemctl -i poweroff</command></action>
        </item>
      </menu>

      </openbox_menu>
    '';

    environment.etc."xdg/labwc/rc.xml".text = ''
      <?xml version="1.0"?>

      <labwc_config>

        <core>
          <gap>10</gap>
        </core>

        <theme>
          <name></name>
          <cornerRadius>2</cornerRadius>
          <font><name>IBM Plex Sans</name><size>10</size></font>
        </theme>

        <keyboard>
          <default />
          <keybind key="A-Return">
            <action name="Execute"><command>foot</command></action>
          </keybind>
        </keyboard>

      </labwc_config>
    '';

    environment.etc."xdg/labwc/themerc".text = ''
      # Decorator
      window.active.title.bg.color: #2f343f
      window.inactive.title.bg.color: #2f343f
      window.*.label.text.color: #d8dee8
      window.*.button.*.image.color: #d8dee8

      # Borders
      window.handle.width: 0
      window.client.padding.width: 0
      border.width: 0

      # Title
      padding.width: 10
      padding.height: 8
      window.*.title.bg: Solid Flat
      window.*.*.bg: Parentrelative
      window.label.text.justify: center

      # Menu
      menu.border.width: 6
      menu.separator.width: 2
      menu.separator.padding.width: 10
      menu.separator.padding.height: 2
      menu.overlap.x: -8
      menu.*.bg: flat solid
      menu.*.bg.color: #2f343f
      menu.*.color: #2f343f
      menu.title.text.color: #ffffff
      menu.items.text.color: #d8dee8
      menu.items.active.disabled.text.color: #707070
      menu.items.active.text.color: #d8dee8
      menu.title.text.justify: center
      menu.items.active.bg.color: #5294e2

      # OSD
      osd.border.width: 1
      osd.border.color: #2f343f
      osd.bg: flat solid
      osd.bg.color: #2f343f
      osd.label.bg: flat solid
      osd.label.bg.color: #2f343f
      osd.hilight.bg: flat solid
      osd.hilight.bg.color: #ef6b7b

      # Colour Trick
      window.active.button.close.unpressed.image.color: #ef6b7b
      window.inactive.button.close.unpressed.image.color: #bf616a
    '';
  };
}
