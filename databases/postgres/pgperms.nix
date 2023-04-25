{ lib
, buildGoModule
, fetchFromGitHub
}:

let
  pname = "pgperms";
  version = "0.1.0";
  src = fetchFromGitHub {
    name = "${pname}-${version}-src";
    owner = "SnoozeThis-org";
    repo = pname;
    rev = "9e23a87bece464ed54e5206a24fbba0270cf5c2f";
    hash = "sha256-obUXIL59BiKNP45h2nU9wwWTsFgIDlPDLFlmHlzqeFE=";
  };
in
buildGoModule {
  inherit pname version src;

  vendorHash = "sha256-X1IB1vRK1yJfzEkl40ZH7kw2r61WfMYNaEhyDpifPSQ=";

  doCheck = false;

  meta = {
    description = "Declarative PostgreSQL permissions as code";
    license = lib.licenses.mit;
  };
}
