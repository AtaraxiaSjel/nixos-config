{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkIf
    mkMerge
    mkOption
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

  config = mkMerge [
    (mkIf (role == "base") {
      ataraxia.defaults.nix.enable = true;
    })
  ];
}
