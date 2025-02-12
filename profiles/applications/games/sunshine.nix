{ ... }: {
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };

  # boot.kernelModules = [ "uinput" ];

  # services.udev.extraRules = ''
  #   KERNEL=="uinput", GROUP="input", MODE="0660" OPTIONS+="static_node=uinput"
  # '';

  persist.state.homeDirectories = [ ".config/sunshine" ];
}
