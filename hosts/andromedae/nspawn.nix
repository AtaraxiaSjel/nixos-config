# Declarative systemd-nspawn container with Debian (trixie/forky).
#
# The host part only sets up the .nspawn unit and a one-time service to
# initialize the rootfs via debootstrap. Inside the guest, it's a regular Debian:
# packages are installed with apt, configs are edited manually or via
# machinectl shell.
#
# Networking: veth pair, the host end is attached to the br0 bridge (created by
# ataraxia.networkd). The guest is a full-fledged LAN node, getting an address
# via DHCP from the router. Port forwarding is not needed: ssh directly to the
# guest's IP, tunnels - via ssh -L from the workstation:
#   ssh -L 8080:localhost:8080 root@<container-ip>
{
  config,
  lib,
  pkgs,
  ...
}:
let
  name = "debian";
  suite = "trixie"; # "forky" = testing
  mirror = "https://deb.debian.org/debian";
  rootfs = "/var/lib/machines/${name}";
  stamp = "/var/lib/machines/.${name}.provisioned";
  shareHost = "/srv/nspawn-shared";
  bridge = "br0";

  arch =
    if pkgs.stdenv.hostPlatform.isx86_64 then
      "amd64"
    else if pkgs.stdenv.hostPlatform.isAarch64 then
      "arm64"
    else
      throw "unsupported architecture for debian nspawn container";

  authorizedKeys =
    config.users.users.${config.ataraxia.defaults.users.defaultUser}.openssh.authorizedKeys.keys;
  tmpRootPassword = "ChangeMeAndDeleteMe";

  authorizedKeysFile = pkgs.writeText "${name}-authorized_keys" (
    lib.concatStringsSep "\n" authorizedKeys
  );

  debianArchiveKeyring =
    pkgs.runCommand "debian-archive-keyring"
      {
        src = pkgs.fetchurl {
          url = "mirror://debian/pool/main/d/debian-archive-keyring/debian-archive-keyring_2025.1_all.deb";
          hash = "sha256-nqd3jkQxRMpJBmhzeoqyLdPnSLuZ6AXiLsBVq+s8f6w=";
        };
      }
      ''
        mkdir -p $out
        ${pkgs.dpkg}/bin/dpkg-deb -x $src $out
      '';

  provision = pkgs.writeShellScript "provision-${name}-rootfs" ''
    set -euo pipefail
    export DEBIAN_FRONTEND=noninteractive

    if [ ! -e ${stamp} ] && [ -d ${rootfs} ]; then
      rm -rf ${rootfs}
    fi

    ${pkgs.debootstrap}/bin/debootstrap \
      --arch=${arch} \
      --variant=minbase \
      --include=systemd,systemd-sysv,dbus,openssh-server,ca-certificates,curl,git,iproute2,less,systemd-resolved,iputils-ping,bind9-dnsutils \
      --keyring=${debianArchiveKeyring}/usr/share/keyrings/debian-archive-keyring.gpg \
      ${suite} ${rootfs} ${mirror} \
      ${pkgs.debootstrap}/share/debootstrap/scripts/gutsy

    # --- minimal setup for guest ---
    # network: DHCP on host0 (this is the veth interface inside the container)
    mkdir -p ${rootfs}/etc/systemd/network
    {
      echo '[Match]'
      echo 'Name=host0'
      echo
      echo '[Network]'
      echo 'DHCP=yes'
    } > ${rootfs}/etc/systemd/network/40-host0.network

    # autostart networkd/resolved/sshd on first boot
    install -d ${rootfs}/etc/systemd/system/multi-user.target.wants
    for u in systemd-networkd.service systemd-resolved.service ssh.service; do
      ln -sfn /lib/systemd/system/$u \
        ${rootfs}/etc/systemd/system/multi-user.target.wants/$u
    done

    # accessible via ssh
    install -dm700 ${rootfs}/root/.ssh
    ${
      if authorizedKeys != [ ] then
        "install -m600 ${authorizedKeysFile} ${rootfs}/root/.ssh/authorized_keys"
      else
        ''
          echo "root:${tmpRootPassword}" | ${pkgs.util-linux}/bin/chroot ${rootfs} /usr/sbin/chpasswd
          echo "!!! WARNING: temporary root password '${tmpRootPassword}' set - change it !!!"''
    }

    touch ${stamp}
  '';
in
{
  # generate nspawn config file /etc/systemd/nspawn/debian.nspawn
  systemd.nspawn.${name} = {
    execConfig = {
      Boot = true;
      ResolvConf = "delete";
    };
    filesConfig.Bind = [
      "${shareHost}:/shared"
    ];
    networkConfig = {
      VirtualEthernet = true;
      Bridge = bridge;

      # NB: not working in bridge mode - traffic goes around host stack
      # If need it, remove Bridge=, add networking.nat with
      # internalInterfaces = [ "vb-+" ] and uncomment:
      # Port = [ "tcp:2222:22" "tcp:8000:8000" ];
    };
  };

  # singleshot service to provision the rootfs
  systemd.services."provision-${name}" = {
    description = "Bootstrap Debian (${suite}) rootfs for nspawn machine ${name}";
    wantedBy = [ "machines.target" ];
    before = [ "systemd-nspawn@${name}.service" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    unitConfig.ConditionPathExists = "!${stamp}";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      TimeoutStartSec = "45min";
      ExecStart = provision;
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/machines 0755 root root -"
    "d ${shareHost} 0777 root root -"
  ];
}
