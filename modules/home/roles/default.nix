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
        programs.nix-index.enable = mkDefault true;
        programs.nix-index-database.comma.enable = mkDefault true;

        persist.enable = mkDefault true;
        persist.cache.clean.enable = mkDefault true;
        # Cargo cache
        home.sessionVariables = {
          CARGO_HOME = mkDefault "${config.xdg.dataHome}/cargo";
        };
        persist.cache.directories = [
          ".local/share/cargo"
        ];
      };
      serverRole = recursiveUpdate baseRole { };
      desktopRole = recursiveUpdate baseRole {
        ataraxia.defaults.sound.enable = mkDefault true;
      };
    in
    mkMerge [
      (mkIf (role == "base") baseRole)
      (mkIf (role == "server") serverRole)
      (mkIf (role == "desktop") desktopRole)
    ];
}
