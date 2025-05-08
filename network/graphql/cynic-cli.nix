{ lib
, fetchFromGitHub
, rustPlatform
, openssl
, libiconv
, pkg-config
}:

let
  pname = "cynic-cli";
  version = "3.10.0";
  owner = "obmarg";
  repo = "cynic";

  src = fetchFromGitHub {
    inherit owner repo;
    rev = "a4747951bc76bd484e9bccde2a027af4909bc61e";
    hash = "sha256-+bdupm0hOx6X1kV7HJU6LXuiLQoxaDzAV1/OanLwZzY=";
  };
in
rustPlatform.buildRustPackage {
  inherit pname version src;

  postUnpack = ''
    pushd "source/${pname}/"
    ln -sv ../Cargo.lock .
    popd
  '';

  cargoHash = "sha256-zPdqpzqcwX6BceBITVREaTy3R2by9Qd/VwolgZg83Mo=";
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
