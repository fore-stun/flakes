{ lib
, buildNpmPackage
, fetchFromGitHub
}:

let
  pname = "org-formation";
  version = "v1.0.14";

  src = fetchFromGitHub {
    name = "${pname}-${version}-src";
    owner = "fore-stun";
    repo = "${pname}-cli";
    rev = "42b7339db1e8bae567591b936b4d1a67dfd8bb54";
    hash = "sha256-4KZBSqjUt6s46bWBS1qh5Tc/4iHEPeBf4eBDS4WzIDA=";
  };

in

buildNpmPackage {
  inherit pname version src;

  npmDepsHash = "sha256-ABk6AgfTQidrc3cpuKKscTD23TWs2WaaiO7Ftla02bo=";

  meta = {
    homepage = "https://github.com/org-formation/org-formation-cli";
    description = "An Infrastructure as Code (IaC) tool for AWS Organizations";
    license = lib.licenses.mit;
    mainProgram = pname;
  };
}
