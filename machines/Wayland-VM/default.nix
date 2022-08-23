{ modulesPath, inputs, lib, pkgs, ... }: {
  imports = with inputs.self.nixosModules; with inputs.self.nixosProfiles; [
    # ./hardware-configuration.nix
    "${modulesPath}/profiles/qemu-guest.nix"
    "${modulesPath}/profiles/minimal.nix"
    ./system-path.nix
  ];
  disabledModules = ["config/system-path.nix"];

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
        "rd.systemd.show_status=auto"
        "rd.udev.log_priority=3"
        "pti=off"
        "spectre_v2=off"
        "kvm.ignore_msrs=1"
      ];
    };

    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 60;
      numDevices = 1;
    };

    networking.firewall.enable = false;

    users.mutableUsers = false;
    users.users.alukard = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      uid = 1000;
      hashedPassword = "$6$kDBGyd99tto$9LjQwixa7NYB9Kaey002MD94zHob1MmNbVz9kx3yX6Q4AmVgsFMGUyNuHozXprxyuXHIbOlTcf8nd4rK8MWfI/";
    };

    nix = rec {
      nixPath = lib.mkForce [ "self=/etc/self/compat" "nixpkgs=/etc/nixpkgs" ];

      registry.self.flake = inputs.self;
      registry.nixpkgs.flake = inputs.nixpkgs;

      optimise.automatic = true;

      extraOptions = ''
        experimental-features = nix-command flakes
      '';

      settings = {
        auto-optimise-store = false;
      };
    };

    environment.etc.nixpkgs.source = inputs.nixpkgs;
    environment.etc.self.source = inputs.self;

    environment.systemPackages = [ pkgs.nano pkgs.kitty pkgs.labwc ];
    environment.noXlibs = lib.mkForce false;

    security.polkit.enable = true;

    # nixpkgs.overlays = [(self: super: {
    #   labwc = super.labwc.overrideAttrs (old: {
    #     buildInputs = [ pkgs.libGL ] ++ old.buildInputs;
    #     mesonFlags = [ "-Dxwayland=disabled" ];
    #   });
    #   libdecor = super.libdecor.overrideAttrs (old: {
    #     buildInputs = [ pkgs.libGL ] ++ old.buildInputs;
    #   });
    # })];

    system.stateVersion = "22.11";

    services.getty.autologinUser = "alukard";

    # environment.loginShellInit = lib.mkAfter ''
    #   [[ "$(tty)" == /dev/tty1 ]] && {
    #     exec labwc
    #   }
    # '';

    system.userActivationScripts.linktosharedfolder.text = let
      environment = pkgs.writeText "environment" ''
        XDG_CURRENT_DESKTOP=wlroots
        XKB_DEFAULT_LAYOUT=us,ru
        XKB_DEFAULT_OPTIONS=grp:win_space_toggle
        _JAVA_AWT_WM_NONREPARENTING=1
      '';
      menu-xml = pkgs.writeText "menu.xml" ''
        <?xml version="1.0">
        <openbox_menu>
        <menu id="root-menu" label="">
          <item label="Terminal"><action name="Execute" command="kitty" /></item>
          <item label="Reconfigure"><action name="Reconfigure" /></item>
          <item label="Exit"><action name="Exit" /></item>
        </menu>
        </openbox_menu>
      '';
    in ''
      if [[ -h "$HOME/.config/labwc/environment" ]]; then
        rm -f "$HOME/.config/labwc/environment"
      fi
      if [[ -h "$HOME/.config/labwc/menu.xml" ]]; then
        rm -f "$HOME/.config/labwc/menu.xml"
      fi
      ln -s "${environment}" "$HOME/.config/labwc/environment"
      ln -s "${menu-xml}" "$HOME/.config/labwc/menu.xml"
    '';

    environment.etc."gbinder.d/waydroid.conf".source = let
        waydroidGbinderConf = pkgs.writeText "waydroid.conf" ''
          [General]
          ApiLevel = 29
        '';
      in lib.mkForce waydroidGbinderConf;
    virtualisation.waydroid.enable = true;
    # virtualisation.lxd.enable = true;
  };
}
