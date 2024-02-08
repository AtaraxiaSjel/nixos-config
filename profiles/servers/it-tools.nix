{ ... }: {
  virtualisation.oci-containers.containers.it-tools = {
    autoStart = true;
    image = "docker.io/corentinth/it-tools:latest";
    extraOptions = [ "--pull=newer" ];
    ports = [ "127.0.0.1:8070:80/tcp" ];
  };
}