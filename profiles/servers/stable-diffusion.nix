{ config, lib, pkgs, ... }:
let
  # init = pkgs.writeScript "init.sh" ''
  #   CHANGEME
  # '';
in with config.virtualisation.oci-containers; {
  virtualisation.oci-containers.containers.stable-diffusion = {
    # autoStart = true;
    autoStart = false;
    cmd = [ "./init.sh" ];
    # environment = {
      # COMMANDLINE_ARGS = "--listen --port 7860 --deepdanbooru --medvram --opt-split-attention --disable-console-progressbars --enable-console-prompts";
    # };
    extraOptions = [
      "--device=/dev/kfd"
      "--device=/dev/dri"
      "--group-add=video"
      "--ipc=host"
      "--cap-add=SYS_PTRACE"
      "--security-opt"
      "seccomp=unconfined"
      "--hostname=stable-diffusion-ct"
    ];
    image = "rocm-arch";
    ports = [ "80:7860/tcp" ];
    volumes = [
      "/home/${config.mainuser}/projects/rocm-terminal/shared:/shared"
    ];
  };

  systemd.services."${backend}-stable-diffusion" = {
    preStop = lib.mkForce "${backend} stop -t 10 stable-diffusion";
    serviceConfig.TimeoutStopSec = lib.mkForce 15;
  };

  networking.firewall.allowedTCPPorts = [ 7860 ];
}
