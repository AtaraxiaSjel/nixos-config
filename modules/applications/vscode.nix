{ pkgs, lib, config, ... }:
let
  thmFile = config.lib.base16.templateFile;
  thm = config.lib.base16.theme;
in
{
  home-manager.users.alukard = {
    programs.vscode.enable = true;
    # programs.vscode.package = pkgs.vscode-fhsWithPackages (ps: with ps; [ glibc ]);
    programs.vscode.package = pkgs.vscode;

    home.file.".cache/wal/colors".text = ''
      #${thm.base00-hex}
      #${thm.base08-hex}
      #${thm.base0B-hex}
      #${thm.base0A-hex}
      #${thm.base0D-hex}
      #${thm.base0E-hex}
      #${thm.base0C-hex}
      #${thm.base05-hex}
      #${thm.base03-hex}
      #${thm.base08-hex}
      #${thm.base0B-hex}
      #${thm.base0A-hex}
      #${thm.base0D-hex}
      #${thm.base0E-hex}
      #${thm.base0C-hex}
      #${thm.base07-hex}
    '';
  };

  defaultApplications.editor = {
    cmd = "${pkgs.vscode}/bin/code";
    # cmd = "${pkgs.vscode-fhs}/bin/code";
    desktop = "code";
  };
}
