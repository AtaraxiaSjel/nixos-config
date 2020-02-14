{ buildGoModule, fetchFromGitHub, lib }:
buildGoModule rec {
  pname = "spicetify-cli";
  version = "0.9.7";

  src = fetchFromGitHub {
    owner = "khanhas";
    repo = "spicetify-cli";
    rev = "v${version}";
    sha256 = "1zvihjzv4q4pshvwjjia27vkzcn24phrs5cadc7gbl1mqr3zyac6";
  };

  modSha256 = "1q6vvy2xz2wm2wzpjk04hbfmsjm72wfa3kxfnnc8b4gxhdhw50ql";

  meta = with lib; {
    description = "Commandline tool to customize Spotify client. Supports Windows, MacOS and Linux.";
    homepage = https://github.com/khanhas/spicetify-cli;
    license = licenses.gpl3;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}