{ stdenv, python3Packages, fetchFromGitHub }:

python3Packages.buildPythonApplication rec {
  name = "advance-touch";

  src = fetchFromGitHub {
    owner = "tanrax";
    repo = "terminal-AdvancedNewFile";
    rev = "38481017b65e764db240c8ec3b4c8ed6faafabf9";
    sha256 = "1n4wng4jhmib7zpm7vykprf24rckvh3r1b7sr2navy7ndns6vk3q";
  };

  propagatedBuildInputs = with python3Packages; [ click ];

  meta = {
    homepage = "https://github.com/tanrax/terminal-AdvancedNewFile";
    description = "Add to your terminal the option to quickly create folders and files like a pro";
    license = stdenv.lib.licenses.unlicense;
    maintainers = with stdenv.lib.maintainers; [ alukardbf ];
  };
}