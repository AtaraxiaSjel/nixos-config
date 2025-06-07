{
  config,
  lib,
  inputs,
  ...
}:
let
  inherit (lib)
    mkDefault
    mkIf
    mkMerge
    mkOption
    recursiveUpdate
    types
    ;
  inherit (lib.hm.dag) entryAfter;

  role = config.ataraxia.defaults.role;
in
{
  options.ataraxia.defaults = {
    role = mkOption {
      type = types.enum [
        "none"
        "base"
        "server"
        "desktop"
      ];
      default = "none";
    };
  };

  imports = [
    inputs.nix-index-database.hmModules.nix-index
  ];

  config =
    let
      baseRole = {
        ataraxia.defaults.zsh.enable = mkDefault true;
        ataraxia.security.pass-secret-service.enable = mkDefault true;
        ataraxia.security.password-store.enable = mkDefault true;

        programs.nix-index.enable = mkDefault true;
        programs.nix-index-database.comma.enable = mkDefault true;

        home.activation = {
          remove-nix-legacy = entryAfter [ "writeBoundary" ] ''
            rm -rf ${config.home.homeDirectory}/.nix-defexpr
            unlink ${config.home.homeDirectory}/.nix-profile
          '';
        };

        news.display = "silent";

        persist.enable = mkDefault true;
        persist.cache.clean.enable = mkDefault true;
        # Cargo cache
        home.sessionVariables = {
          CARGO_HOME = mkDefault "${config.xdg.dataHome}/cargo";
        };
        persist.cache.directories = [
          ".local/share/cargo"
        ];

        xdg.configFile."nixpkgs/config.nix".text = mkDefault ''
          { allowUnfree = true; android_sdk.accept_license = true; }
        '';
      };
      serverRole = recursiveUpdate baseRole { };
      desktopRole = recursiveUpdate baseRole {
        ataraxia.defaults.fonts.enable = mkDefault true;
        ataraxia.defaults.sound.enable = mkDefault true;
        ataraxia.programs.vscode.enable = mkDefault true;
      };
    in
    mkMerge [
      (mkIf (role == "base") baseRole)
      (mkIf (role == "server") serverRole)
      (mkIf (role == "desktop") desktopRole)
    ];
}
