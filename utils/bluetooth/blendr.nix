{ lib
, fetchFromGitHub
, rustPlatform
}:

let
  pname = "blendr";
  version = "1.3.3";
  owner = "dmtrKovalenko";
  repo = pname;

  src = fetchFromGitHub {
    inherit owner repo;
    rev = "40c3338156475b7d8391c449e8377a76e3f01656";
    hash = "sha256-koNBuKm1W6AOxq8RlWnR1n0/QyQFAIZwfcgyOuAnzy4=";
  };
in
rustPlatform.buildRustPackage {
  inherit pname version src;

  cargoHash = "sha256-JfFNh++E8+te5O4Loq9cB7IBjf8IAi/om0HJ6wvFtZU=";
  doCheck = false;

  meta = {
    description = "The hacker's BLE (bluetooth low energy) browser terminal app";
    homepage = "https://github.com/${owner}/${repo}";
    license = lib.licenses.bsd3;
    mainProgram = pname;
  };
}
