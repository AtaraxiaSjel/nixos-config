{ ... }: {
  virtualisation.oci-containers.containers.it-tools = {
    autoStart = true;
    # Tags: 2024.10.22-7ca5933
    image = "docker.io/corentinth/it-tools@sha256:8b8128748339583ca951af03dfe02a9a4d7363f61a216226fc28030731a5a61f";
    ports = [ "127.0.0.1:8070:80/tcp" ];
  };
}