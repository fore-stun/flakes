{ self, lib, nixpkgs, ... }:

let
  pnames = [ "simple-markdown" ];
in
lib.foldFor pnames (pname: lib.foldFor lib.platforms.all (system: {
  packages.${system}.${pname} =
    nixpkgs.legacyPackages.${system}.callPackage (./. + "/${pname}.nix") {
      inherit (self.packages.${system}) writers;
      inherit lib;
    };
  apps.${system}.${pname} = {
    type = "app";
    program = self.packages.${system}.${pname} + "/bin/${pname}";
  };
}))
