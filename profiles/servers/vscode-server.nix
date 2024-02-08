{ pkgs, inputs, ... }: {
  imports = [ inputs.vscode-server.nixosModule ];
  services.vscode-server = {
    enable = true;
    nodejsPackage = pkgs.nodejs_18;
    #installPath = "~/.vscode-server-oss";
  };

  persist.state.homeDirectories = [ ".vscode-server" ];
}
