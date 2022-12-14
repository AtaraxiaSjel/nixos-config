{ config, lib, pkgs, inputs, ... }: {
  home-manager.sharedModules = [
    inputs.vscode-server-fixup.nixosModules.home-manager.nixos-vscode-server
  ];

  home-manager.users.${config.mainuser} = {
    services.vscode-server.enable = true;
  };

  # persist.state.homeDirectories = [ ".vscode-server" ];
}
