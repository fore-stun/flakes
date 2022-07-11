{ lib, nixpkgs, ... }:

let
  pname = "oracle-cloud-agent";
  systems = [ "x86_64-linux" "aarch64-linux" ];
in
lib.forSystems systems (system: {
  packages.${system}.${pname} =
    nixpkgs.legacyPackages.${system}.callPackage ./package.nix { };
})
