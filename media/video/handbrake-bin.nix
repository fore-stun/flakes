{ lib
, handbrake-cli-bin
, handbrake-gui-bin
, handbrake
, symlinkJoin
}:

let

  inherit (handbrake) pname;
  inherit (handbrake-cli-bin) meta;
  version = "1.8.2";

in
symlinkJoin {
  name = "${pname}-${version}";
  inherit pname version meta;
  buildInputs = [ ];

  paths = [ handbrake-cli-bin handbrake-gui-bin ];
}
