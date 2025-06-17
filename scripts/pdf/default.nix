{ self, lib, nixpkgs, ... }:

let
  pnames = [
    "pdf-print-reorder"
  ];
in
{
  overlays.pdf = final: prev:
    let
      extras = { };
    in
    lib.foldFor pnames (pname: {
      ${pname} = prev.callPackage (./. + "/${pname}.nix") ({
        inherit (final) writers;
        inherit lib;
      } // extras."${pname}" or { });
    });
} //
lib.foldFor lib.platforms.all (system:
  {
    packages.${system} = self.overlays.pdf
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
