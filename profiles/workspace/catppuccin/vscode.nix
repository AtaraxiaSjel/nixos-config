{ cfg }: { config, lib, pkgs, inputs, ... }: {
  home-manager.users.${config.mainuser} = {
    programs.vscode = {
      extensions = let
        ext-vscode = inputs.nix-vscode-marketplace.extensions.${pkgs.system}.vscode-marketplace;
      in [
        ext-vscode.alexdauenhauer.catppuccin-noctis
        ext-vscode.catppuccin.catppuccin-vsc-icons
        (inputs.catppuccin-vsc.packages.${pkgs.system}.catppuccin-vsc.override {
          accent = cfg.accent;
          boldKeywords = false;
          italicComments = false;
          italicKeywords = false;
          extraBordersEnabled = false;
          workbenchMode = "flat";
          bracketMode = "dimmed";
          colorOverrides = {
            mocha = {
              base = "#1c1c2d";
              mantle = "#191925";
              crust = "#151511";
            };
          };
          customUIColors = {
            "statusBar.foreground" = "accent";
          };
        })
      ];
      userSettings = {
        "editor.semanticHighlighting.enabled" = lib.mkForce true;
        "terminal.integrated.minimumContrastRatio" = lib.mkForce 1;
        "window.titleBarStyle" = lib.mkForce "custom";
        "workbench.colorTheme" = lib.mkForce "Catppuccin ${cfg.flavorUpper}";
        "workbench.iconTheme" = lib.mkForce "catppuccin-${cfg.flavor}";
      };
    };
  };
}