{ config, inputs, ... }:
let
  defaultUser = config.ataraxia.defaults.users.defaultUser;
in
{
  # imports = [
  #   inputs.noctalia.nixosModules.default
  # ];

  networking.networkmanager.enable = true;
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  home-manager.users.${defaultUser} = {
    imports = [
      inputs.noctalia.homeModules.default
    ];

    programs.noctalia = {
      enable = true;
      systemd.enable = true;
    };

    persist.state.directories = [
      ".config/noctalia"
      ".local/state/noctalia"
    ];
  };
}
