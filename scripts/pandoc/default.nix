{ self, lib, nixpkgs, ... }:

let
  pnames = [ "simple-markdown" ];
in
{
  overlays.pandoc = final: prev: lib.foldFor pnames (pname: {
    ${pname} = prev.callPackage (./. + "/${pname}.nix") {
      inherit (final) writers;
      inherit lib;
    };
  });
} //
lib.foldFor lib.platforms.all (system:
  {
    packages.${system} = self.overlays.pandoc
      self.packages.${system}
      nixpkgs.legacyPackages.${system};
  } //
  lib.foldFor pnames (pname: {
    apps.${system}.${pname} = {
      type = "app";
      program = self.packages.${system}.${pname} + "/bin/${pname}";
    };
  })
)
