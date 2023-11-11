{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.virtualisation.libvirt.guests;
  diskOptions.options = {
    diskFile = mkOption {
      type = types.str;
      default = "/var/lib/libvirt/images/guest-${name}.qcow2";
    };
    # TODO
    bus = mkOption {
      type = types.enum [ "virtio" "ide" "scsi" "sata" ];
      default = "virtio";
    };
    type = mkOption {
      type = types.enum [ "raw" "qcow2" ];
      default = "qcow2";
    };
    targetName = mkOption {
      type = types.str;
      default = "vda";
    };
    discard = mkOption {
      type = types.enum [ "ignore" "unmap" ];
      default = "unmap";
    };
    cache = mkOption {
      type = types.enum [ "none" "writethrough" "writeback" "directsync" "unsafe" ];
      default = "writeback";
    };
  };
  mountOptions.options = {
    sourceDir = mkOption {
      type = types.str;
      default = "";
    };
    targetDir = mkOption {
      type = types.str;
      default = "";
    };
    # TODO
    type = mkOption {
      type = types.enum [ "virtiofs" "9p" ];
      default = "virtiofs";
    };
  };
  guestsOptions = { name, ... }: {
    options = rec {
      xmlFile = mkOption {
        type = with types; nullOr path;
        default = null;
      };
      connectUri = mkOption {
        type = types.str;
        default = "qemu:///system";
      };
      user = mkOption {
        type = types.str;
        default = "qemu-libvirtd";
      };
      group = mkOption {
        type = types.str;
        default = "qemu-libvirtd";
      };
      autoStart = mkOption {
        type = types.bool;
        default = false;
      };
      autoDefine = mkOption {
        type = types.bool;
        default = true;
      };
      guestOsType = mkOption {
        type = types.enum [ "linux" "windows" ];
        default = "linux";
      };
      uefi = mkOption {
        type = types.bool;
        default = false;
      };
      memory = mkOption {
        type = types.int;
        default = 1024;
      };
      sharedMemory = mkOption {
        type = types.bool;
        # TODO: not needed if using 9p mount
        default = devices.mounts != [ ];
      };
      cpu = {
        sockets = mkOption {
          type = types.int;
          default = 1;
        };
        cores = mkOption {
          type = types.int;
          default = 1;
        };
        threads = mkOption {
          type = types.int;
          default = 1;
        };
      };
      devices = {
        disks = mkOption {
          type = with types; listOf (submodule diskOptions);
          default = [ ];
        };
        mounts = mkOption {
          type = with types; listOf (submodule mountOptions);
          default = [ ];
        };
        tablet = mkOption {
          type = types.bool;
          default = true;
        };
        serial = mkOption {
          type = types.bool;
          default = true;
        };
        qemuGuestAgent = mkOption {
          type = types.bool;
          default = guestOsType != "windows";
        };
        audio = {
          enable = mkOption {
            type = types.bool;
            default = true;
          };
          type = mkOption {
            # TODO
            type = types.enum [
              "none"
              "alsa"
              "coreaudio"
              "dbus"
              "jack"
              "oss"
              "pulseaudio"
              "sdl"
              "spice"
              "file"
            ];
            default = "spice";
          };
        };
        graphics = {
          enable = mkOption {
            type = types.bool;
            # TODO: must be true if video == true?
            default = true;
          };
          type = mkOption {
            # TODO
            type =
              types.enum [ "sdl" "vnc" "spice" "rdp" "desktop" "egl-headless" ];
            default = "spice";
          };
        };
        video = {
          enable = mkOption {
            type = types.bool;
            default = true;
          };
          type = mkOption {
            # TODO
            type = types.enum [
              "vga"
              "cirrus"
              "vmvga"
              "xen"
              "vbox"
              "qxl"
              "virtio"
              "gop"
              "bochs"
              "ramfb"
              "none"
            ];
            default = "virtio";
          };
        };
        network = {
          enable = mkOption {
            type = types.bool;
            default = true;
          };
          interfaceType = mkOption {
            # TODO
            type = types.enum [ "network" "macvlan" "bridge" ];
            default = "network";
          };
          modelType = mkOption {
            type = types.enum [ "virtio" "e1000" ];
            default = "virtio";
          };
          macAddress = mkOption {
            type = with types; nullOr str;
            default = null;
          };
          active = mkOption {
            type = types.bool;
            default = true;
          };
          sourceDev = mkOption {
            type = types.str;
            default = "default";
          };
        };
      };
      timeout = mkOption {
        type = types.int;
        default = 10;
      };
    };
  };
in {
  options.virtualisation.libvirt.guests = mkOption {
    default = { };
    type = types.attrsOf (types.submodule guestsOptions);
  };

  config.systemd.services = lib.mkMerge (lib.mapAttrsToList (
    name: guest: let
      xml = pkgs.writeText "libvirt-guest-${name}.xml" ''
        <domain type="kvm">
          <name>${name}</name>
          <uuid>UUID</uuid>
          <memory unit="MiB">${toString guest.memory}</memory>
          ${
            lib.optionalString guest.sharedMemory ''
              <memoryBacking>
                <source type="memfd"/>
                <access mode="shared"/>
              </memoryBacking>
            ''
          }
          <vcpu placement="static">${
            with guest.cpu;
            toString (sockets * cores * threads)
          }</vcpu>
          <os>
            <type arch="x86_64" machine="pc-q35-7.2">hvm</type>
            ${
              lib.optionalString guest.uefi ''
                <loader readonly="yes" type="pflash">/run/libvirt/nix-ovmf/OVMF_CODE.fd</loader>
                <nvram template="/run/libvirt/nix-ovmf/OVMF_CODE.fd">/var/lib/libvirt/qemu/nvram/${name}_VARS.fd</nvram>
              ''
            }
          </os>
          <features>
            <acpi/>
            <apic/>
            ${
              lib.optionalString (guest.guestOsType == "windows") ''
                <pae/>
                <hyperv mode="custom">
                  <relaxed state="on"/>
                  <vapic state="on"/>
                  <spinlocks state="on" retries="8191"/>
                  <vpindex state="on"/>
                  <synic state="on"/>
                </hyperv>
              ''
            }
            <vmport state="off"/>
          </features>
          <cpu mode="host-passthrough" check="none" migratable="on">
          ${
            with guest.cpu; ''
              <topology
                sockets="${toString sockets}"
                cores="${toString cores}"
                threads="${toString threads}"
              />
            ''
          }
          </cpu>
          <clock offset="${
            if guest.guestOsType == "windows" then "localtime" else "utc"
          }">
            <timer name="rtc" tickpolicy="catchup"/>
            <timer name="pit" tickpolicy="delay"/>
            <timer name="hpet" present="no"/>
            ${
              lib.optionalString (guest.guestOsType == "windows") ''
                <timer name="hypervclock" present="yes"/>
              ''
            }
          </clock>
          <pm>
            <suspend-to-mem enabled="no"/>
            <suspend-to-disk enabled="no"/>
          </pm>
          <devices>
            <emulator>/run/libvirt/nix-emulators/qemu-system-x86_64</emulator>
            ${
              lib.concatStrings (map (disk: ''
                <disk type="file" device="disk">
                  <driver name="qemu" type="${disk.type}" cache="${disk.cache}" discard="${disk.discard}"/>
                  <source file="${disk.diskFile}"/>
                  <target dev="${disk.targetName}" bus="${disk.bus}"/>
                </disk>
              '') guest.devices.disks)
            }
            ${
              lib.concatStrings (map (mount: ''
                <filesystem type="mount" accessmode="passthrough">
                  <driver type="virtiofs" queue="1024"/>
                  <binary path="/run/current-system/sw/bin/virtiofsd" xattr="on">
                    <cache mode="always"/>
                    <lock posix="on" flock="on"/>
                  </binary>
                  <source dir="${mount.sourceDir}"/>
                  <target dir="${mount.targetDir}"/>
                </filesystem>
              '') guest.devices.mounts)
            }
            ${
              with guest.devices.network;
              if enable then
                if interfaceType == "network" then ''
                  <interface type="network">
                    ${
                      lib.optionalString (macAddress != null) ''
                        <mac address="${macAddress}"/>
                      ''
                    }
                    <source network="${sourceDev}"/>
                    <model type="${modelType}"/>
                  </interface>
                '' else if interfaceType == "bridge" then ''
                  <interface type="bridge">
                  ${lib.optionalString (macAddress != null) ''
                    <mac address="${macAddress}"/>
                  ''}
                    <source bridge="${sourceDev}"/>
                    <model type="${modelType}"/>
                  </interface>
                '' else if interfaceType == "macvlan" then ''
                  <interface type="direct">
                  ${lib.optionalString (macAddress != null) ''
                    <mac address="${macAddress}"/>
                  ''}
                    <source dev="${sourceDev}" mode="bridge"/>
                    <model type="${modelType}"/>
                  </interface>
                '' else
                  ""
              else
                ""
            }
            ${
              lib.optionalString guest.devices.tablet ''
                <input type="tablet" bus="usb"/>
              ''
            }
            ${
              lib.optionalString guest.devices.serial ''
                <serial type="pty"/>
              ''
            }
            ${
              lib.optionalString guest.devices.qemuGuestAgent ''
                <channel type="unix">
                  <target type="virtio" name="org.qemu.guest_agent.0"/>
                </channel>
              ''
            }
            ${
              lib.optionalString guest.devices.audio.enable ''
                <audio id="1" type="${guest.devices.audio.type}"/>
                <sound model="ich9"/>
              ''
            }
            ${
              if guest.devices.graphics.enable then
                if guest.devices.graphics.type == "spice" then ''
                  <graphics type="spice" autoport="yes">
                    <listen type="address"/>
                    <image compression="off"/>
                  </graphics>
                '' else
                  ""
              else
                ""
            }
            ${
              with guest.devices.video;
              with lib;
              optionalString enable ''
                <video>
                ${if type == "virtio" then ''
                  <model type="virtio" heads="1"/>
                '' else if type == "qxl" then ''
                  <model type="qxl" ram="65536" vram="65536" vgamem="16384" heads="1"/>
                '' else
                  ""}
                </video>
              ''
            }
            <channel type="spicevmc">
              <target type="virtio" name="com.redhat.spice.0"/>
            </channel>
            <input type="mouse" bus="ps2"/>
            <input type="keyboard" bus="ps2"/>
            <redirdev bus='usb' type='spicevmc'/>
            <memballoon model="virtio"/>
            ${
              lib.optionalString (guest.guestOsType == "windows") ''
                <rng model="virtio">
                  <backend model="random">/dev/urandom</backend>
                </rng>
              ''
            }
          </devices>
        </domain>
      '';
    in {
      "libvirt-guest-define-${name}" = {
        after = [ "libvirtd.service" ];
        requires = [ "libvirtd.service" ];
        wantedBy = lib.mkIf guest.autoDefine [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = "no";
          User = guest.user;
          Group = guest.group;
        };
        environment = { LIBVIRT_DEFAULT_URI = guest.connectUri; };
        script = if guest.xmlFile != null then ''
          ${pkgs.libvirt}/bin/virsh define --file ${guest.xmlFile}
          ${pkgs.libvirt}/bin/virsh net-start ${guest.devices.network.sourceDev} || true
        '' else ''
          uuid="$(${pkgs.libvirt}/bin/virsh domuuid '${name}' || true)"
          ${pkgs.libvirt}/bin/virsh define <(sed "s/UUID/$uuid/" '${xml}')
          ${lib.optionalString
          (guest.devices.network.interfaceType == "network")
          "${pkgs.libvirt}/bin/virsh net-start ${guest.devices.network.sourceDev} || true"}
        '';
      };
      "libvirtd-guest-${name}" = {
        after = [ "libvirt-guest-define-${name}.service" ];
        requires = [ "libvirt-guest-define-${name}.service" ];
        wantedBy = lib.mkIf guest.autoStart [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = "yes";
          User = guest.user;
          Group = guest.group;
        };
        environment = { LIBVIRT_DEFAULT_URI = guest.connectUri; };
        script = "${pkgs.libvirt}/bin/virsh start '${name}'";
        preStop = ''
          ${pkgs.libvirt}/bin/virsh shutdown '${name}'
          let "timeout = $(date +%s) + ${toString guest.timeout}"
          while [ "$(${pkgs.libvirt}/bin/virsh list --name | grep --count '^${name}$')" -gt 0 ]; do
            if [ "$(date +%s)" -ge "$timeout" ]; then
              ${pkgs.libvirt}/bin/virsh destroy '${name}'
            else
              sleep 0.5
            fi
          done
        '';
      };
    }
  ) cfg);
}
