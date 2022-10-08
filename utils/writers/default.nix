{ lib, nixpkgs, ... }:

let
  pnames = [ "writePythonBin" "writeZshBin" ];
in
lib.foldFor pnames (pname: lib.foldFor lib.platforms.all (system: {
  packages.${system}.writers.${pname} =
    nixpkgs.legacyPackages.${system}.callPackage (./. + "/${pname}.nix") { };
}))