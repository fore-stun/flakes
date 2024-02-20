{ self, lib, nixpkgs, ... }:

let
  pnames = [ "pysplit" ];
in
{
  overlays.text = final: prev: lib.foldFor pnames (pname: {
    ${pname} = prev.callPackage (./. + "/${pname}.nix") {
      inherit (final) writers;
    };
  });
} //
lib.foldFor lib.platforms.all (system:
  {
    packages.${system} = self.overlays.text
      self.legacyPackages.${system}
      nixpkgs.legacyPackages.${system};
  } //
  lib.foldFor pnames (pname: {
    apps.${system}.${pname} = {
      type = "app";
      program = self.packages.${system}.${pname} + "/bin/${pname}";
    };
  })
)
