{ pkgs, ... }: {
  defaultApplications.browser = {
    cmd = "${pkgs.vivaldi}/bin/vivaldi";
    desktop = "vivaldi";
  };

  home-manager.users.alukard.home.packages = with pkgs; [
    (vivaldi.override { proprietaryCodecs = true; })
  ];
}