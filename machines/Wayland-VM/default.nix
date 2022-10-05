{ modulesPath, inputs, lib, pkgs, ... }: {
  imports = [
    # ./hardware-configuration.nix
    "${modulesPath}/profiles/qemu-guest.nix"
    "${modulesPath}/profiles/minimal.nix"
    ./imports/system-path.nix
    ./imports/qemu-vm.nix
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

    nixpkgs.overlays = [
      (self: super: {
        labwc = super.labwc.overrideAttrs (old: {
          mesonFlags = [ "-Dxwayland=disabled" ];
        });
        waydroid-script = let
          py = super.python3.withPackages (pythonPackages: with pythonPackages; [
            tqdm
            requests
          ]);
        in super.stdenv.mkDerivation {
          name = "myscript";
          version = "git";

          src = super.fetchFromGitHub {
            repo = "waydroid_script";
            owner = "AlukardBF";
            rev = "d8eaf667220c5ef72519280354d373a149e041a3";
            sha256 = "1m15x87c7pc7ag624zccjjb19ixki01c0pfr78myc8nbavi56lfz";
          };

          buildInputs = [
            py
            super.lzip
            super.sqlite
            super.util-linux
          ];
          installPhase = ''
            mkdir -p $out/bin
            cp waydroid_extras.py $out/bin/waydroid-script
            chmod +x $out/bin/waydroid-script
            sed -i '1i #!${py}/bin/python' $out/bin/waydroid-script
          '';
        };
      })
    ];

    environment.systemPackages = [
      # pkgs.util-linux
      pkgs.labwc
      pkgs.nano
      pkgs.havoc
      pkgs.gnused
      pkgs.ncftp
      pkgs.waydroid-script
    ];

    environment.sessionVariables = {
      LIBSEAT_BACKEND = "logind";
    };

    i18n.defaultLocale = "en_GB.UTF-8";
    console.font = "cyr-sun16";
    console.keyMap = "ruwin_cplk-UTF-8";

    fonts.enableDefaultFonts = lib.mkForce false;

    environment.noXlibs = lib.mkForce false;

    security.polkit.enable = true;

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
        labwc -s havoc
      }
    '';

    system.userActivationScripts.linktosharedfolder.text = let
      havoc = pkgs.writeText "havoc.cfg" ''
        [child]
        program=bash
        [font]
        size=18
        path=${pkgs.ibm-plex}/share/fonts/truetype/VictorMono-Regular.ttf
      '';
    in ''
      if [[ ! -d "$HOME/.config" ]]; then
        mkdir -p $HOME/.config
      fi
      if [[ -h "$HOME/.config/havoc.cfg" ]]; then
        rm -f "$HOME/.config/havoc.cfg"
      fi
      ln -s "${havoc}" "$HOME/.config/havoc.cfg"
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
          <action name="Execute"><command>havoc</command></action>
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
          <keybind key="A-Tab">
            <action name="NextWindow" />
          </keybind>
          <keybind key="A-w">
            <action name="Execute"><command>havoc</command></action>
          </keybind>
          <keybind key="A-q">
            <action name="Close" />
          </keybind>
          <keybind key="A-a">
            <action name="ToggleMaximize" />
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

    system.stateVersion = "22.11";
  };
}
