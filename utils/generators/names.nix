{ lib
, fetchFromGitHub
, rustPlatform
}:

let
  pname = "names";
  version = "0.14.0";
  owner = "fnichol";
  repo = pname;

  src = fetchFromGitHub {
    inherit owner repo;
    rev = "b5023b03e2339bf6e860bdcef20557ab81f3ec55";
    hash = "sha256-1jvr4zkzR50TXQSq4BnOB+nqnjRyNuvaSF413xjKYDg=";
  };
in
rustPlatform.buildRustPackage {
  inherit pname version src;

  cargoHash = "sha256-KX490W2JU8jKSMu+FtfPHsH0h9n9GXa3y8VcDVlMwBo=";
  doCheck = false;

  meta = {
    description = "Random name generator for Rust";
    homepage = "https://github.com/${owner}/${repo}";
    license = lib.licenses.mit;
    mainProgram = pname;
  };
}
