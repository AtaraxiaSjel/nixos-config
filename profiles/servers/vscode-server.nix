{ config, lib, pkgs, inputs, ... }: {
  home-manager.sharedModules = [
    inputs.vscode-server-fixup.nixosModules.home-manager.nixos-vscode-server
  ];

  home-manager.users.${config.mainuser} = {
    services.vscode-server = {
      enable = true;
      extensions =
        with inputs.nix-vscode-marketplace.packages.${pkgs.system}.vscode;
        # [ jnoortheen.nix-ide ];
        [ bbenoist.nix ];
      immutableExtensionsDir = true;
      # settings = {
      #  "nix.enableLanguageServer" = true;
      #  "nix.serverPath" = "${inputs.rnix-lsp.defaultPackage.${pkgs.system}}/bin/rnix-lsp";
      # };
    };
  };

  # persist.state.homeDirectories = [ ".vscode-server" ];
}
