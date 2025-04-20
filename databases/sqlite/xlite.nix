{ lib
, fetchFromGitHub
, rustPlatform
, stdenv
}:

let
  pname = "xlite";
  version = "0.2.1";
  owner = "x2bool";
  repo = pname;

  src = fetchFromGitHub {
    inherit owner repo;
    rev = "5d36c8dd3f367750aa9d84f3c7d54ae042f2a6bc";
    hash = "sha256-/TVgc87KXpvHIOk/xkid5jhZaXg9KwyhrVPdwhffRds=";
  };

  lockFile = builtins.path {
    path = ./xlite/Cargo.lock;
  };

  EXT_DIR = "lib/sqlite/ext/";
  outFile = "libxlite${stdenv.hostPlatform.extensions.sharedLibrary}";

in
rustPlatform.buildRustPackage {
  inherit pname version src;

  cargoLock = { inherit lockFile; };

  rustTargetPlatformSpec = stdenv.hostPlatform.rust.rustcTargetSpec;

  inherit EXT_DIR;
  passthru = {
    # Consumers need to know the actual output file
    libPath = "${EXT_DIR}${outFile}";
  };

  postPatch = ''
    ln -s ${lockFile} Cargo.lock
    substituteInPlace tests/lib.rs \
      --replace-fail 'target/debug' "target/$rustTargetPlatformSpec/release"
  '';

  postInstall = ''
    local INSTALL_DIR="$out/$EXT_DIR"
    mkdir -p "$INSTALL_DIR"
    mv "$out/lib/${outFile}" "$INSTALL_DIR"
  '';

  meta = {
    description = "SQLite extension for querying Excel (.xlsx, .xls, .ods) files as virtual tables";
    homepage = "https://github.com/${owner}/${repo}";
    license = lib.licenses.mit;
  };
}
