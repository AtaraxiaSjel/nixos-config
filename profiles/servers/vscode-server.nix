{ config, lib, pkgs, inputs, ... }: {
  services.vscode-server = {
    enable = true;
    nodejsPackage = pkgs.nodejs-16_x;
    #installPath = "~/.vscode-server-oss";
  };

  persist.state.homeDirectories = [ ".vscode-server" ];
}
