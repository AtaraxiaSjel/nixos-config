{ config, lib, pkgs, inputs, ... }: {
  home-manager.sharedModules = [
    inputs.vscode-server-fixup.nixosModules.home-manager.nixos-vscode-server
  ];

  home-manager.users.alukard = {
    services.vscode-server.enable = true;
  };
}
