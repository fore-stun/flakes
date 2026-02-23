{ lib
, fetchFromGitHub
, llmfit
}:

let
  inherit (llmfit) pname;
  owner = "AlexsJones";
  repo = pname;
  version = "0.4.1";
  upstream = llmfit.version;

  src = fetchFromGitHub {
    name = "${pname}-${version}-src";
    inherit owner repo;
    rev = "ec35061cb90b16d5495e2b1804c614a537826874";
    hash = "sha256-zyDHJ23DmgXFbayarK9ie2BT4TcGPcbiThYuC0fGY/8=";
  };

  drv = llmfit.overrideAttrs {
    inherit version src;
    cargoLock = null;
    cargoHash = "";
  };
in

if version > upstream then drv else llmfit
