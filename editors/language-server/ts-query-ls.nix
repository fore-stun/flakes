{ lib
, cmake
, fetchFromGitHub
, rustPlatform
}:

let
  pname = "ts_query_ls";
  version = "v1.0.0";
  owner = "ribru17";
  repo = pname;

  src = fetchFromGitHub {
    inherit owner repo;
    rev = "02397890609124143eb7fcd2d9d9df7759c4771d";
    hash = "sha256-rmP1jCT1cs+kq9axgVNM0nHPYMQ0ihJuh9izd2tBbzc=";
  };
in
rustPlatform.buildRustPackage {
  inherit pname version src;

  nativeBuildInputs = [
    # Needed for `wasmtime-c-api-impl v25.0.2`
    cmake
  ];

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    outputHashes = {
      "tree-sitter-query-0.4.0" = "sha256-snr0ze1VCaAf448mHkrB9qbWTMvjSlPdVl2VtesMIHI=";
    };
  };
  doCheck = false;

  meta = {
    description = "An LSP implementation for Tree-sitter's query files";
    homepage = "https://github.com/${owner}/${repo}";
    license = lib.licenses.mit;
    mainProgram = pname;
  };
}
