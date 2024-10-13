{ lib
, fetchFromGitHub
, rustPlatform
}:

let
  pname = "stu";
  version = "0.6.4";
  owner = "lusingander";
  repo = pname;

  src = fetchFromGitHub {
    inherit owner repo;
    rev = "1c2f09c770a0c32bfb576ee050f7e643e0a604f0";
    hash = "sha256-iLfUJXunQjS/dFB+sTtZRvsxHRMh5o6JYM3eCucEhQA=";
  };
in
rustPlatform.buildRustPackage {
  inherit pname version src;

  cargoHash = "sha256-eja2wE822IckT9pj6TqqKh3NUyUox+VlhGb+lTvCW1Y=";
  doCheck = false;

  meta = {
    description = "TUI explorer application for Amazon S3 (AWS S3) 🪣";
    homepage = "https://github.com/${owner}/${repo}";
    license = lib.licenses.mit;
    mainProgram = pname;
  };
}
