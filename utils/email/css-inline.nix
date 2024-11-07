{ lib
, fetchFromGitHub
, rustPlatform
}:

let
  pname = "css-inline";
  version = "0.14.1";
  owner = "Stranger6667";
  repo = pname;

  src = fetchFromGitHub {
    inherit owner repo;
    rev = "69c68eb1ec683340a9ddaed8ada5e13cd88ec188";
    hash = "sha256-vxV5KXCPwxIedZSqrIh/RDOr4VT3/BFbII4Q2zp6yI8=";
  };

  lockFile = builtins.path {
    path = ./css-inline/Cargo.lock;
  };

in
rustPlatform.buildRustPackage {
  inherit pname version src;

  sourceRoot = "${src.name}/${pname}";

  cargoLock = { inherit lockFile; };

  postPatch = ''
    ln -s ${lockFile} Cargo.lock
  '';

  checkFlags = [
    # Require network
    "--skip=keep_link_tags"
    "--skip=remote_network_relative_stylesheet"
    "--skip=remote_network_stylesheet"
    "--skip=remote_network_stylesheet_same_scheme"
  ];

  meta = {
    description = "High-performance library for inlining CSS into HTML 'style' attributes";
    homepage = "https://css-inline.org/";
    license = lib.licenses.mit;
    mainProgram = pname;
  };
}
