{ lib
, buildNpmPackage
, fetchFromGitHub
}:

let
  pname = "org-formation";
  version = "v1.0.13";

  src = fetchFromGitHub {
    name = "${pname}-${version}-src";
    owner = "fore-stun";
    repo = "${pname}-cli";
    rev = "6187fd19094bb5e4139937efd7a82c14877d94c6";
    hash = "sha256-7LE5uOVZa9GUMJMoqaPIRS9QAjuatc37ujEVC74JJ2E=";
  };

in

buildNpmPackage {
  inherit pname version src;

  npmDepsHash = "sha256-9H8ip70s7PI+i/lo4zPugAYAxMD47odm0a1IZhqliRM=";

  meta = {
    homepage = "https://github.com/org-formation/org-formation-cli";
    description = "An Infrastructure as Code (IaC) tool for AWS Organizations";
    license = lib.licenses.mit;
    mainProgram = pname;
  };
}
