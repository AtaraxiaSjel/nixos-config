{ ... }: {
  virtualisation.oci-containers.containers.battery-historian = {
    autoStart = true;
    ports = [ "0.0.0.0:9999:9999" ];
    image = "gcr.io/android-battery-historian/stable:3.0";
  };
}