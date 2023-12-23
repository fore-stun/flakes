{ lib
, fetchFromGitHub
, rustPlatform
}:

let
  pname = "xlite";
  version = "0.2.0";
  owner = "x2bool";
  repo = pname;

  src = fetchFromGitHub {
    inherit owner repo;
    rev = "4c76e55b7ff7983033dba0f4f2e0e4315d6c8212";
    hash = "sha256-zjzPpwg2UoI522dhMg1af5fneuLgZmqjyxij9RpmB/o=";
  };
in
rustPlatform.buildRustPackage {
  inherit pname version src;

  cargoHash = lib.fakeHash;
  doCheck = false;

  meta = {
    description = "Query Excel spredsheets (.xlsx, .xls, .ods) using SQLite";
    homepage = "https://github.com/${owner}/${repo}";
    license = lib.licenses.mit;
  };
}
