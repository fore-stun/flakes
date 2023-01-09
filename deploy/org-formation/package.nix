{ lib
, buildNpmPackage
, fetchFromGitHub
}:

let
  pname = "org-formation";
  version = "v1.0.6";

  src = fetchFromGitHub {
    name = "${pname}-${version}-src";
    owner = pname;
    repo = "${pname}-cli";
    rev = "2a29c927b7cdda914fbead2fd2bf6b9a34f3b2d5";
    hash = "sha256-DVtOXgnpb1tOI1Ifo2BN7/gO4Hu8vrUuvZvgCkBdVLA=";
  };

in

buildNpmPackage {
  inherit pname version src;

  npmDepsHash = "sha256-tUc/YNZNmgK/roVO2cFsiRyaTJOVBrGMXJaP73az67c=";

  meta = {
    homepage = "https://github.com/org-formation/org-formation-cli";
    description = "An Infrastructure as Code (IaC) tool for AWS Organizations";
    license = lib.licenses.mit;
  };
}
