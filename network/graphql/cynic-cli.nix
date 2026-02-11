{ lib
, fetchFromGitHub
, rustPlatform
, openssl
, libiconv
, pkg-config
}:

let
  pname = "cynic-cli";
  version = "3.12.0";
  owner = "obmarg";
  repo = "cynic";

  src = fetchFromGitHub {
    inherit owner repo;
    rev = "a7cce2bf06d0c7ad3ffcf9fea47d8f4626095249";
    hash = "sha256-1fkhtxxI87qAEhEPpda/GSHl/FxkZkNJU1C5lVr7d18=";
  };
in
rustPlatform.buildRustPackage {
  inherit pname version src;

  postUnpack = ''
    pushd "source/${pname}/"
    ln -sv ../Cargo.lock .
    popd
  '';

  cargoHash = "sha256-1/y6mozV8mTunO+eYSg/3gzIn8rYPUOk2iVNq2g+zTI=";
  cargoRoot = pname;
  doCheck = false;

  nativeBuildInputs = [
    libiconv
    openssl
    pkg-config
  ];

  PKG_CONFIG_PATH = "${openssl.dev}/lib/pkgconfig";

  meta = {
    description = "A CLI for Cynic, the code first GraphQL client for Rust";
    homepage = "https://github.com/${owner}/${repo}";
    license = lib.licenses.mpl20;
    mainProgram = pname;
  };
}
