{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkDefault
    mkEnableOption
    mkIf
    ;
in
{
  options.ataraxia.profiles.minimal = mkEnableOption "minimal profile";

  # Upstream nixpkgs doesn't support disabling profile
  # imports = [
  #   (modulesPath + "/profiles/minimal.nix")
  # ];

  config = mkIf config.ataraxia.profiles.minimal {
    # This pulls in nixos-containers which depends on Perl.
    boot.enableContainers = mkDefault false;

    documentation = {
      enable = mkDefault false;
      doc.enable = mkDefault false;
      info.enable = mkDefault false;
      man.enable = mkDefault false;
      nixos.enable = mkDefault false;
    };

    environment = {
      # Perl is a default package.
      defaultPackages = mkDefault [ ];
      stub-ld.enable = mkDefault false;
    };

    programs = {
      # The lessopen package pulls in Perl.
      less.lessopen = mkDefault null;
      command-not-found.enable = mkDefault false;
    };

    services = {
      logrotate.enable = mkDefault false;
      udisks2.enable = mkDefault false;
    };

    xdg = {
      autostart.enable = mkDefault false;
      icons.enable = mkDefault false;
      mime.enable = mkDefault false;
      sounds.enable = mkDefault false;
    };
  };
}
