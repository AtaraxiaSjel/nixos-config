{ pkgs, lib, config, ... }: {
  programs.steam.enable = true;
  hardware.steam-hardware.enable = true;

  startupApplications = [
    "${pkgs.steam}/bin/steam"
  ];

  home-manager.users.alukard.wayland.windowManager.sway.config = {
    assigns = {
      "0" = [
        { class = "^Steam$"; }
      ];
    };
    window.commands = (
      map (title: { command = "floating enable"; criteria = { class = "^Steam$"; inherit title; }; })
      [
        "Steam - News" ".* - Chat" "^Settings$" ".* - event started" ".* CD key" "^Steam - Self Updater$"
        "^Screenshot Uploader$" "^Steam Guard - Computer Authorization Required$"
      ]
    ) ++ [
      {
        command = "floating enable";
        criteria = { title = "^Steam Keyboard$"; };
      }
    ];
  };
}