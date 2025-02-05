{ lib
, fetchFromGitHub
, rustPlatform
}:

let
  pname = "json-diff";
  version = "0.1.2";
  owner = "ksceriath";
  repo = pname;

  src = fetchFromGitHub {
    inherit owner repo;
    rev = "a7ed330667456bfafc345634f4bdb2ec8d527171";
    hash = "sha256-MBS+8WPQuhO04AS02x8+56EgKr2TwaC+VI2pr95UzsA=";
  };
in
rustPlatform.buildRustPackage {
  inherit pname version src;

  cargoHash = "sha256-kfRqioKJseM10QvxQKVs9F0VxHHEQBQnZnNqAq980Vc=";
  doCheck = false;

  meta = {
    description = "A command line utility to compare two jsons";
    homepage = "https://github.com/${owner}/${repo}";
    license = lib.licenses.unlicense;
    mainProgram = "json_diff";
  };
}
