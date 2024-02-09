{ ... }: {
  virtualisation.oci-containers.containers.it-tools = {
    autoStart = true;
    image = "docker.io/corentinth/it-tools:2023.12.21-5ed3693";
    ports = [ "127.0.0.1:8070:80/tcp" ];
  };
}