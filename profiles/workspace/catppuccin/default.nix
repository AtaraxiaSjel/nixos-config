{ config, lib, inputs, ... }: {
  imports = let
    cfg = rec {
      thm = config.lib.base16.theme;
      # this capitalizes the first letter in a string.
      mkUpper =
        str:
        (lib.toUpper (builtins.substring 0 1 str)) +
        (builtins.substring 1 (builtins.stringLength str) str);

      accent = "mauve";
      flavor = "mocha";
      size = "standard"; # "standard" "compact"
      tweaks = [ "normal" ]; # "black" "rimless" "normal"
      flavorUpper = mkUpper flavor;
      accentUpper = mkUpper accent;
      sizeUpper = mkUpper size;
      gtkTheme = if flavor == "latte" then "Light" else "Dark";
    };
  in  [
    inputs.catppuccin.nixosModules.catppuccin
    # Custom modules
    (import ./catppuccin.nix { inherit cfg; })
    # Until https://github.com/catppuccin/nix/pull/179 is merged
    (import ./gitea.nix { inherit cfg; gitea = "gitea"; })
    # Deprecated on catppuccin-nix
    (import ./gtk.nix { inherit cfg; })
  ];

  home-manager.users.${config.mainuser} = {
    imports = [ inputs.catppuccin.homeManagerModules.catppuccin ];
  };
}