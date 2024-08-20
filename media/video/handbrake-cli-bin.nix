{ lib
, darwin
, fetchurl
, hostPlatform
, handbrake
, stdenvNoCC
, undmg
}:

let

  inherit (handbrake) pname meta;
  version = "1.8.2";

  src = let name = "${pname}-${version}.dmg"; in
    fetchurl
      {
        inherit name;
        urls = [
          "https://github.com/HandBrake/HandBrake/releases/download/${version}/HandBrakeCLI-${version}.dmg"
        ];
        hash = "sha256-Tfw9cO9bYMhv2MrIfiF062usMqAfnD6cXiLzyxImRsU=";
      };

  handbrakeCliBin = stdenvNoCC.mkDerivation {
    pname = "${pname}-cli";
    inherit src version;
    sourceRoot = ".";

    meta = meta // {
      platforms = lib.platforms.darwin;
      broken = false;
      mainProgram = "HandBrakeCLI";
    };

    nativeBuildInputs = [
      undmg
    ];

    installPhase = ''
      mkdir -p "$out/bin"
      cp -pR "HandBrakeCLI" "$out/bin/"

      mkdir -p "$out/share/"
      cp -pR "doc" "$out/share/"
    '';
  };

in
handbrakeCliBin
