{ config, pkgs, ... }: {
  home-manager.users.${config.mainuser} = {
    home.packages = with pkgs; [
      tdesktop
    ];
  };

  defaultApplications.messenger = {
    cmd = "${pkgs.tdesktop}/bin/telegram-desktop";
    desktop = "telegram-desktop";
  };

  startupApplications = with config.defaultApplications; [
    messenger.cmd
  ];

  persist.state.homeDirectories = [
    ".local/share/TelegramDesktop"
  ];
}