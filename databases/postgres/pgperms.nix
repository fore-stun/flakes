{ lib
, buildGoModule
, fetchFromGitHub
}:

let
  pname = "pgperms";
  version = "0.1.1";
  src = fetchFromGitHub {
    name = "${pname}-${version}-src";
    owner = "SnoozeThis-org";
    repo = pname;
    rev = "a50358c5ba504ad2d6744fb63c6db04959814c96";
    hash = "sha256-S1+cBmHSwHIOv+FLSfpGflXyAKTDnsgmth7YhugFpCI=";
  };
in
buildGoModule {
  inherit pname version src;

  vendorHash = "sha256-LV1Lndbh1UGaukgBVAiHdcqZVyE19LpC+asErVORbfU=";

  doCheck = false;

  meta = {
    description = "Declarative PostgreSQL permissions as code";
    license = lib.licenses.mit;
  };
}
