{ config, lib, pkgs, ... }: {
  services.barrier = if config.device == "NixOS-VM" then {
    server.enable = true;
    server.autoStart = true;
    server.configFile = pkgs.writeTextFile {
      name = "barrier.conf";
      text = ''
        section: screens
          NixOS-VM:
        	Dell-Laptop:
        end
        section: links
        	Dell-Laptop:
        		right = NixOS-VM
        end
        section: options
            keystroke(super+alt+left) = switchInDirection(left)
            keystroke(super+alt+right) = switchInDirection(right)
        end
      '';
    };
  } else {
    client.enable = true;
    client.serverAddress = "NixOS-VM";
  };
}