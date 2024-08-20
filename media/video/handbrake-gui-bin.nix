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
          "https://github.com/HandBrake/HandBrake/releases/download/${version}/HandBrake-${version}.dmg"
        ];
        hash = "sha256-pZ3Ba2qmzlBBZyYgs+6+LlG7MgXkvQpWI1nL8TI7LYQ=";
      };

  handbrakeBin = stdenvNoCC.mkDerivation {
    pname = "${pname}-gui";
    inherit src version;
    sourceRoot = ".";

    meta = meta // {
      platforms = lib.platforms.darwin;
      broken = false;
    };

    nativeBuildInputs = [
      undmg
    ];

    installPhase = ''
      mkdir -p "$out/Applications/"
      cp -pR "HandBrake.app" "$out/Applications/"
    '';
  };

in
handbrakeBin
