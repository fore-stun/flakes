{ lib
, cmake
, fetchFromGitHub
, rustPlatform
}:

let
  pname = "ts_query_ls";
  version = "v1.2.2";
  owner = "ribru17";
  repo = pname;

  src = fetchFromGitHub {
    inherit owner repo;
    rev = "f3fe133bfe0f9e17e7404ec7357738be023b798a";
    hash = "sha256-TJRG33V5nfbJgTaXwP3YDN5pSQKMrFZeLSsrIYy5I1A=";
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
