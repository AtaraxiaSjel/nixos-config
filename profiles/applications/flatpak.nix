{ pkgs, ... }: {
  services.flatpak.enable = true;
  xdg.portal.enable = true;

  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };

  persist.state = {
    directories = [ "/var/lib/flatpak" ];
    homeDirectories = [ ".local/share/flatpak" ".var" ];
  };
}