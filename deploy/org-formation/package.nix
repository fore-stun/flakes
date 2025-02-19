{ lib
, buildNpmPackage
, fetchFromGitHub
}:

let
  pname = "org-formation";
  version = "v1.0.16";

  src = fetchFromGitHub {
    name = "${pname}-${version}-src";
    owner = "fore-stun";
    repo = "${pname}-cli";
    rev = "960072bf920d935de90156b2d0f5c31b377039bb";
    hash = "sha256-cQ5DUPCdOiXkL9Uumc7BgxuqanQLk9AuqBSUoSFV+4s=";
  };

in

buildNpmPackage {
  inherit pname version src;

  npmDepsHash = "sha256-Kd3JjNqF9fAKEllXm07xOHiq9B7EXVkYsoHTbK0/bhs=";

  meta = {
    homepage = "https://github.com/org-formation/org-formation-cli";
    description = "An Infrastructure as Code (IaC) tool for AWS Organizations";
    license = lib.licenses.mit;
    mainProgram = pname;
  };
}
