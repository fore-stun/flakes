{ lib
, fetchFromGitHub
, rustPlatform
, openssl
, libiconv
, pkg-config
}:

let
  version = "0.10.0";
  owner = "oxidecomputer";
  repo = "progenitor";
  pname = "cargo-${repo}";

  src = fetchFromGitHub {
    inherit owner repo;
    rev = "77bcb82c0c6d3b831df5930227861a1a3d143386";
    hash = "sha256-cyz34XjfMBzkWDgHo5NFRNTEr2dIalkUVC4W+Rah3Bs=";
  };
in
rustPlatform.buildRustPackage {
  inherit pname version src;

  cargoHash = "sha256-zrVBEnV0kaA5t4sscM6u3YGZNMJY1eE9WBu/yDsyV/o=";
  doCheck = false;

  nativeBuildInputs = [
    libiconv
    openssl
    pkg-config
  ];

  PKG_CONFIG_PATH = "${openssl.dev}/lib/pkgconfig";

  postInstall = ''
    mkdir -p "$out/share/examples"
    for exe in $out/bin/example-*; do
      mv "$exe" "$out/share/examples/"
    done
  '';

  meta = {
    description = "An OpenAPI client generator";
    homepage = "https://github.com/${owner}/${repo}";
    license = lib.licenses.mpl20;
    mainProgram = pname;
  };
}
