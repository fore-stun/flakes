{ lib
, buildNpmPackage
, fetchFromGitHub
, nodejs_latest
}:

let
  pname = "org-formation";
  version = "v1.0.11";

  src = fetchFromGitHub {
    name = "${pname}-${version}-src";
    owner = "fore-stun";
    repo = "${pname}-cli";
    rev = "83f4d373ed90ccd6763c98d9ec20ce8da630333b";
    hash = "sha256-a10nsOkguDh/1hsfSUc1zznQ0GuRqYN5B0sV5e4xqx4=";
  };

in

buildNpmPackage.override { nodejs = nodejs_latest; } {
  inherit pname version src;

  npmDepsHash = "sha256-+vsY9zxIYAKkh2QnssuotM/BnzC6Vn0isYn48FOlkOw=";

  meta = {
    homepage = "https://github.com/org-formation/org-formation-cli";
    description = "An Infrastructure as Code (IaC) tool for AWS Organizations";
    license = lib.licenses.mit;
    mainProgram = pname;
  };
}
