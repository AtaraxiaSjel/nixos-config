{ ... }: {
  virtualisation.oci-containers.containers.it-tools = {
    autoStart = true;
    image = "docker.io/corentinth/it-tools:2024.5.13-a0bc346";
    ports = [ "127.0.0.1:8070:80/tcp" ];
  };
}