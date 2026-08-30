{ lib
, buildGoModule
, fetchFromGitHub
}:

let
  pname = "huggingface-model-downloader";
  repo = "HuggingFaceModelDownloader";
  mainProgram = "hfdownloader";
  version = "1.3.4";
  src = fetchFromGitHub {
    name = "${pname}-${version}-src";
    owner = "bodaay";
    inherit repo;
    rev = "2f38356a6d6ce9c7731eb48bee35d795a4f1f67c";
    hash = "sha256-cDrFQTo9E112UFtam40kQ+lxPStSg4Edx1fjK2WyWHw=";
  };
in
buildGoModule {
  inherit pname version src;

  vendorHash = "sha256-0tAJEPJQJTUYoV0IU2YYmSV60189rDRdwoxQsewkMEU=";

  doCheck = false;

  meta = {
    description = "Simple go utility to download HuggingFace Models and Datasets";
    license = lib.licenses.asl20;
    inherit mainProgram;
  };

  postInstall = ''
    mv -v "$out/bin/${repo}" "$out/bin/${mainProgram}"
  '';
}
