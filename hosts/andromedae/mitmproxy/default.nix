{
  config,
  lib,
  pkgs,
  ...
}:
let
  defaultUser = config.ataraxia.defaults.users.defaultUser;
in
{
  security.pki.certificateFiles = [ ./mitmproxy-ca-cert.pem ];

  home-manager.users.${defaultUser} =
    let
      mitmproxy-wrapped = pkgs.symlinkJoin {
        inherit (pkgs.opencode) meta version;
        name = "${lib.getName pkgs.mitmproxy}-wrapped-${lib.getVersion pkgs.mitmproxy}";
        paths = [ pkgs.mitmproxy ];
        preferLocalBuild = true;
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/mitmproxy \
            --add-flags "--set confdir=\"\$HOME/.config/mitmproxy\""
          wrapProgram $out/bin/mitmweb \
            --add-flags "--set confdir=\"\$HOME/.config/mitmproxy\""
          wrapProgram $out/bin/mitmdump \
            --add-flags "--set confdir=\"\$HOME/.config/mitmproxy\""
        '';
      };
    in
    {
      home.packages = [ mitmproxy-wrapped ];
      persist.state.directories = [ ".config/mitmproxy" ];
    };
}
