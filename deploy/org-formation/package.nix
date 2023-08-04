{ lib
, buildNpmPackage
, fetchFromGitHub
}:

let
  pname = "org-formation";
  version = "v1.0.11";

  src = fetchFromGitHub {
    name = "${pname}-${version}-src";
    owner = pname;
    repo = "${pname}-cli";
    rev = "d85980f5e1eaa586bf044a5be0f557295f210689";
    hash = "sha256-RLH+5vEOVX444J3Ct0x1HqlSpbAyyBj1bYdgPJ9N8Ec=";
  };

in

buildNpmPackage {
  inherit pname version src;

  npmDepsHash = "sha256-edOc1cp4RdoplHG6UCV8XQ1ohi3zRxMkp9iMJfTHNak=";

  meta = {
    homepage = "https://github.com/org-formation/org-formation-cli";
    description = "An Infrastructure as Code (IaC) tool for AWS Organizations";
    license = lib.licenses.mit;
    mainProgram = pname;
  };
}
