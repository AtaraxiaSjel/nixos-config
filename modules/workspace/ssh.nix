{ pkgs, lib, config, ... }: {

  home-manager.users.alukard = {
    # programs.ssh = {
    #   enable = true;
    #   forwardAgent = true;
    #   extraOptions = {
    #     # Host = "localhost";
    #     AddKeysToAgent = "ask";
    #   }
    # };
    home.file.".ssh/config".text = ''
      Host localhost
      ForwardAgent yes
      AddKeysToAgent ask
      Match host * exec "gpg-connect-agent UPDATESTARTUPTTY /bye"
    '';
  };
}
