{ config, lib, pkgs, inputs, ... }: {
  home-manager.sharedModules = [
    inputs.vscode-server-fixup.nixosModules.home
  ];

  home-manager.users.alukard = {
    services.vscode-server-fixup.enable = true;
  };
}
