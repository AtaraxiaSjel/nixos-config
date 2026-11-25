{
  config,
  lib,
  pkgs,
  useHomeManager,
  ...
}:
let
  defaultUser = config.ataraxia.defaults.users.defaultUser;
in
{
  boot.extraModprobeConfig = ''
    options kvm_amd nested=1
  '';
  boot.extraModulePackages = [
    ((pkgs.linuxKernel.packagesFor config.boot.kernelPackages.kernel).kvmfr.overrideAttrs (oa: {
      nativeBuildInputs = (oa.nativeBuildInputs or [ ]) ++ [ pkgs.removeReferencesTo ];
      makeFlags = (oa.makeFlags or [ ]) ++ [ "INSTALL_MOD_STRIP=1" ];
      postFixup = (oa.postFixup or "") + ''
        find "$out/lib/modules" -name '*.ko' -exec \
          remove-references-to -t "${config.boot.kernelPackages.kernel.dev}" {} +
      '';

    }))
  ];
  boot.initrd.kernelModules = [ "kvmfr" ];
  boot.kernelParams = [ "kvmfr.static_size_mb=64" ];

  environment.systemPackages = with pkgs; [
    looking-glass-client
  ];

  services.udev.packages = lib.singleton (
    pkgs.writeTextFile {
      name = "kvmfr";
      text = ''
        SUBSYSTEM=="kvmfr", GROUP="kvm", MODE="0660", TAG+="uaccess"
      '';
      destination = "/etc/udev/rules.d/70-kvmfr.rules";
    }
  );

  virtualisation.libvirtd.qemu = {
    verbatimConfig = ''
      namespaces = []
      cgroup_device_acl = [
        "/dev/null", "/dev/full", "/dev/zero",
        "/dev/random", "/dev/urandom",
        "/dev/ptmx", "/dev/kvm", "/dev/kqemu",
        "/dev/rtc","/dev/hpet", "/dev/vfio/vfio",
        "/dev/kvmfr0"
      ]
    '';
  };

  home-manager = lib.mkIf useHomeManager {
    users.${defaultUser} = {
      persist.state.directories = [
        ".config/looking-glass"
      ];
    };
  };
}
