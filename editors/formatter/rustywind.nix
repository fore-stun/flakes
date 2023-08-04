{ lib
, fetchFromGitHub
, rustPlatform
}:

let
  pname = "rustywind";
  version = "0.16.0";
  owner = "avencera";
  repo = pname;

  src = fetchFromGitHub {
    inherit owner repo;
    rev = "83288658bedeffffdbb9390215d0389319a0e07a";
    hash = "sha256-xDpRS8WrFu5uPtbXJGXrxElJinxl1lkpYZ1tGrNrBHA=";
  };
in
rustPlatform.buildRustPackage {
  inherit pname version src;

  cargoHash = "sha256-2bo6KkHVw1lyLD4iWidAyxZzQMRTO5DWvYmqUQld15g=";
  doCheck = false;

  meta = {
    description = "CLI for organizing Tailwind CSS classes";
    homepage = "https://github.com/${owner}/${repo}";
    license = lib.licenses.mit;
    mainProgram = pname;
  };
}
