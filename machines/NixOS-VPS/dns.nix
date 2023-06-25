{ config, lib, pkgs, ... }:
let
  inherit (import ./hardware/networks.nix) interfaces;
  wgIfname = interfaces.wireguard0.ifname;
  brIfname = interfaces.main'.bridgeName;
in {
  services.resolved.extraConfig = ''
    DNSStubListener=off
  '';
  systemd.network.networks."20-${brIfname}".networkConfig.DNS = lib.mkForce "127.0.0.1";
  systemd.network.networks."90-${wgIfname}".networkConfig.DNS = lib.mkForce "127.0.0.1";

  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };

  environment.systemPackages = with pkgs; [ tcpdump dnsutils ];
  services.blocky = {
    enable = true;
    settings = {
      upstream.default = [ "127.0.0.1:553" "[::1]:553" ];
      upstreamTimeout = "10s";
      bootstrapDns = [{ upstream = "9.9.9.9"; }];
      blocking = {
        blackLists.ads = [
          "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
        ];
        clientGroupsBlock.default = [ "ads" ];
      };
      port = 53;
      queryLog = {
        type = "console";
      };
    };
  };
  # TODO: DoH (https://unbound.docs.nlnetlabs.nl/en/latest/topics/privacy/dns-over-https.html)
  services.unbound = {
    enable = true;
    settings = {
      server = {
        root-hints = "${config.services.unbound.stateDir}/root.hints";
        port = "553";
        interface = [
          "127.0.0.1" "10.100.0.1"
          "::1" "fd3a:900e:8e74:ffff::1"
        ];
        access-control = [
          "0.0.0.0/0 refuse"
          "127.0.0.0/8 allow"
          "10.100.0.0/16 allow"
          "::0/0 refuse"
          "::1 allow"
          "fd3a:900e:8e74:ffff::0/64 allow"
        ];
        private-address = [
          "127.0.0.0/8"
          "10.100.0.0/16"
          "::1"
          "fd3a:900e:8e74:ffff::0/64"
        ];
	      hide-version = "yes";
        aggressive-nsec = "yes";
        cache-max-ttl = "86400";
        cache-min-ttl = "600";
        deny-any = "yes";
        do-ip4 = "yes";
        do-ip6 = "yes";
        do-tcp = "yes";
        do-udp = "yes";
        harden-algo-downgrade = "yes";
        harden-dnssec-stripped = "yes";
        harden-glue = "yes";
        harden-large-queries = "yes";
        harden-referral-path = "yes";
        harden-short-bufsize = "yes";
        hide-identity = "yes";
        minimal-responses = "yes";
        msg-cache-size = "128m";
        neg-cache-size = "4m";
        prefer-ip6 = "no";
        prefetch = "yes";
        prefetch-key = "yes";
        qname-minimisation = "yes";
        rrset-cache-size = "256m";
        rrset-roundrobin = "yes";
        serve-expired = "yes";
        so-rcvbuf = "4m";
        so-reuseport = "yes";
        so-sndbuf = "4m";
        unwanted-reply-threshold = "100000";
        use-caps-for-id = "yes";
      };
    };
  };
  systemd.services.root-hints = {
    script = ''
      ${pkgs.wget}/bin/wget -O ${config.services.unbound.stateDir}/root.hints https://www.internic.net/domain/named.root
    '';
    serviceConfig.Type = "oneshot";
    startAt = "1 0 1 */1 *";
  };
}