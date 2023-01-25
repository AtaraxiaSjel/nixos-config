{ config, lib, pkgs, inputs, ... }: {
  home-manager.sharedModules = [
    inputs.vscode-server-fixup.nixosModules.home-manager.nixos-vscode-server
  ];

  home-manager.users.${config.mainuser} = let
    extensions = builtins.tryEval config.home-manager.users.${config.mainuser}.programs.vscode.extensions;
  in {
    services.vscode-server = {
      enable = true;
      extensions = if extensions.success then extensions.value
      else with inputs.nix-vscode-marketplace.packages.${pkgs.system}.vscode; [
        bbenoist.nix
      ];
      immutableExtensionsDir = true;
    };
  };

  persist.state.homeDirectories = [ ".vscode-server" ];
}
