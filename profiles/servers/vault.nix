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

  sops.secrets.vault-keys-env.sopsFile = inputs.self.secretsDir + /home-hypervisor/vault.yaml;
  systemd.services.vault-unseal = {
    wantedBy = [ "multi-user.target" ];
    partOf = [ "vault.service" ];
    after = [ "vault.service" ];
    path = [ pkgs.curl pkgs.jq ];
    script = ''
      set -a
      source ${config.sops.secrets.vault-keys-env.path}
      while true; do
        initialized=$(curl -s ${api-addr}/v1/sys/health | jq -r '.initialized')
        [[ "$initialized" = "true" ]] && break
        echo "Vault has not been initialized yet. Will try again after 5 seconds." >&2
        sleep 5
      done
      curl -H "Content-Type: application/json" --data "{\"key\":\"$VAULT_KEY1\"}" ${api-addr}/v1/sys/unseal >/dev/null 2>&1
      curl -H "Content-Type: application/json" --data "{\"key\":\"$VAULT_KEY2\"}" ${api-addr}/v1/sys/unseal >/dev/null 2>&1
      curl -H "Content-Type: application/json" --data "{\"key\":\"$VAULT_KEY3\"}" ${api-addr}/v1/sys/unseal >/dev/null 2>&1
    '';
    serviceConfig.Type = "oneshot";
  };

  persist.state.directories = [ config.services.vault.storagePath ];
}