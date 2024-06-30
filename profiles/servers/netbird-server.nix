{ config, lib, inputs, ... }:
let
  svc-pass = config.sops.secrets.netbird-svc-pass.path;
  store-key = config.sops.secrets.netbird-store-key.path;

  domain = "net.ataraxiadev.com";
  client-id = "GI2nPUZfBoAOgYWoQpWHopE4awUz3Tx3W5LYOaz1";
  issuer = "https://auth.ataraxiadev.com/application/o/netbird";
  scopes = "openid profile email offline_access api groups";
in {
  sops.secrets = let
    cfg = {
      sopsFile = inputs.self.secretsDir + /home-hypervisor/netbird.yaml;
      restartUnits = [ "netbird-management.service" ];
    };
  in {
    netbird-store-key = cfg;
    netbird-svc-pass = cfg;
  };

  services.netbird.server = {
    enable = true;
    inherit domain;
    enableNginx = true;
    coturn.enable = false;
    signal.logLevel = "INFO";
    dashboard.settings = {
      AUTH_AUTHORITY = issuer;
      AUTH_CLIENT_ID = client-id;
      AUTH_SUPPORTED_SCOPES = scopes;
    };
    management = {
      disableAnonymousMetrics = lib.mkForce true;
      logLevel = "INFO";
      dnsDomain = "netbird.local";
      singleAccountModeDomain = "netbird.local";
      oidcConfigEndpoint = "${issuer}/.well-known/openid-configuration";

      turnDomain = config.services.coturn.realm;
      turnPort = config.services.coturn.listening-port;
      settings = {
        DataStoreEncryptionKey._secret = store-key;
        DeviceAuthorizationFlow = {
          Provider = "hosted";
          ProviderConfig = {
            Audience = client-id;
            ClientID = client-id;
            DeviceAuthEndpoint = "https://auth.ataraxiadev.com/application/o/device/";
            RedirectURLs = null;
            Scope = "openid";
            TokenEndpoint = "https://auth.ataraxiadev.com/application/o/token/";
            UseIDToken = false;
          };
        };
        HttpConfig = {
          AuthAudience = client-id;
          AuthIssuer = "https://auth.ataraxiadev.com/application/o/netbird/";
          AuthKeysLocation = "https://auth.ataraxiadev.com/application/o/netbird/jwks/";
          # AuthUserIDClaim = "";
          IdpSignKeyRefreshEnabled = false;
        };
        IdpManagerConfig = {
          ManagerType = "authentik";
          ClientConfig = {
            ClientID = client-id;
            GrantType = "client_credentials";
            Issuer = "https://auth.ataraxiadev.com/application/o/netbird/";
            TokenEndpoint = "https://auth.ataraxiadev.com/application/o/token/";
          };
          ExtraConfig = {
            Password._secret = svc-pass;
            Username = "Netbird";
          };
        };
        PKCEAuthorizationFlow = {
          ProviderConfig = {
            Audience = client-id;
            AuthorizationEndpoint = "https://auth.ataraxiadev.com/application/o/authorize/";
            ClientID = client-id;
            Scope = scopes;
            TokenEndpoint = "https://auth.ataraxiadev.com/application/o/token/";
            UseIDToken = false;
          };
        };
        TURNConfig = {
          Secret._secret = config.sops.secrets.auth-secret.path;
          TimeBasedCredentials = true;
          # Not used, supress nix warnind about world-readable password
          # Password._secret = config.sops.secrets.auth-secret.path;
        };
      };
    };
  };

  services.nginx.virtualHosts.${domain} = {
    useACMEHost = "ataraxiadev.com";
    enableACME = false;
    forceSSL = true;
  };

  persist.state.directories = [ "/var/lib/netbird-mgmt" ];
}