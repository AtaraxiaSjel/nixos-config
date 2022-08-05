{ config, lib, pkgs, ... }: {
  virtualisation.oci-containers.containers.battery-historian = {
    autoStart = true;
    ports = [ "127.0.0.1:9999:9999" ];
    image = "gcr.io/android-battery-historian/stable:3.0";
  };
}