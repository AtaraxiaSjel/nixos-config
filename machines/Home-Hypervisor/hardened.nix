{ modulesPath, config, pkgs, lib, ... }: {
  imports = [
    "${toString modulesPath}/profiles/hardened.nix"
  ];

  boot.kernel.sysctl = {
    # "kernel.sysrq" = false;
    "net.core.default_qdisc" = "sch_fq_codel";
    "net.ipv4.conf.all.accept_source_route" = false;
    "net.ipv4.icmp_ignore_bogus_error_responses" = true;
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.ipv4.tcp_fastopen" = 3;
    "net.ipv4.tcp_rfc1337" = true;
    "net.ipv4.tcp_syncookies" = true;
    "net.ipv6.conf.all.accept_source_route" = false;
    # disable ipv6
    "net.ipv6.conf.all.disable_ipv6" = true;
    "net.ipv6.conf.default.disable_ipv6" = true;
  };

  # security.lockKernelModules = false;
  security.allowSimultaneousMultithreading = true;
  security.virtualisation.flushL1DataCache = "cond";
  # security.forcePageTableIsolation = false;

  # scudo memalloc is unstable
  # environment.memoryAllocator.provider = lib.mkForce "libc";
  environment.memoryAllocator.provider = lib.mkForce "graphene-hardened";

  boot.kernel.sysctl."net.ipv4.conf.all.log_martians" = false;
  boot.kernel.sysctl."net.ipv4.conf.all.rp_filter" = "0";
  boot.kernel.sysctl."net.ipv4.conf.default.log_martians" = false;
  boot.kernel.sysctl."net.ipv4.conf.default.rp_filter" = "0";
}