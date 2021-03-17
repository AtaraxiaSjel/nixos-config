{ pkgs, lib, ... }: {
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    # config = { };
    # media-session = {
    #   enable = true;
    #   # config = { };
    #   alsaMonitorConfig = {
    #     rules = [
    #       {
    #         matches = [
    #           { node.name = "~alsa_input.*"; }
    #           { node.name = "~alsa_output.*"; }
    #         ];
    #         actions = {
    #           update-props = {
    #             resample.quality = 6;
    #             audio.rate = 48000;
    #           };
    #         };
    #       }
    #     ];
    #   };
    # };
  };

  security.rtkit.enable = true;

  home-manager.users.alukard.home.packages = [ pkgs.pavucontrol pkgs.pulseaudio ];

  hardware.pulseaudio.enable = lib.mkForce false;
  services.jack.jackd.enable = lib.mkForce false;
}