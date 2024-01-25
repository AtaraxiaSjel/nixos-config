{ config, pkgs, inputs, ... }:
let
  api-addr = "http://127.0.0.1:8200";
in {
  environment.systemPackages = [ config.services.vault.package ];
  services.vault = {
    enable = true;
    package = pkgs.vault-bin;
    address = "127.0.0.1:8200";
    storageBackend = "raft";
    storageConfig = ''
      node_id = "main_node"
    '';
    extraConfig = ''
      disable_cache = true
      api_addr = "${api-addr}"
      cluster_addr = "https://127.0.0.1:8201"
      ui = true
    '';
  };

  sops.secrets.vault-key1.sopsFile = inputs.self.secretsDir + /home-hypervisor/vault.yaml;
  sops.secrets.vault-key2.sopsFile = inputs.self.secretsDir + /home-hypervisor/vault.yaml;
  sops.secrets.vault-key3.sopsFile = inputs.self.secretsDir + /home-hypervisor/vault.yaml;
  systemd.services.vault-unseal = {
    partOf = [ "vault.service" ];
    after = [ "vault.service" ];
    path = [ pkgs.curl ];
    script = ''
      KEY1=$(head -n1 ${config.sops.secrets.vault-key1.path})
      KEY2=$(head -n1 ${config.sops.secrets.vault-key2.path})
      KEY3=$(head -n1 ${config.sops.secrets.vault-key3.path})
      curl -H "Content-Type: application/json" --data "{\"key\":\"$KEY1\"}" ${api-addr}/v1/sys/unseal >/dev/null 2>&1
      curl -H "Content-Type: application/json" --data "{\"key\":\"$KEY2\"}" ${api-addr}/v1/sys/unseal >/dev/null 2>&1
      curl -H "Content-Type: application/json" --data "{\"key\":\"$KEY3\"}" ${api-addr}/v1/sys/unseal >/dev/null 2>&1
    '';
    serviceConfig.Type = "oneshot";
  };

  persist.state.directories = [ config.services.vault.storagePath ];
}