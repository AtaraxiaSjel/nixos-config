{ pkgs, ... }: {
  services.vscode-server = {
    enable = true;
    nodejsPackage = pkgs.nodejs_16;
    #installPath = "~/.vscode-server-oss";
  };

  persist.state.homeDirectories = [ ".vscode-server" ];
}
