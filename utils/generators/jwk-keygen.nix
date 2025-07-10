{ lib
, buildGoModule
, fetchFromGitHub
}:

let
  pname = "jwk-keygen";
  version = "0.1";
  owner = "openstandia";
  repo = pname;
  src = fetchFromGitHub {
    inherit owner repo;
    name = "${pname}-${version}-src";
    rev = "5888cbc5d989319f7a39d1145a853026d1dee269";
    hash = "sha256-my11Gpef4xvm5Yr8HmGKpu9Npv4HHS2qMMiw8JlHAfE=";
  };
in
buildGoModule {
  inherit pname version src;

  vendorHash = "sha256-6UfgzfiSfYlfyoGAeHIqynsscbLFeuDevO5brUaKNH8=";

  meta = {
    description = "JWK Kwy Generator";
    homepage = "https://github.com/${owner}/${repo}/";
    license = lib.licenses.asl20;
    mainProgram = "jwkgen";
  };
}
