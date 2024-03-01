{ self, lib, nixpkgs, ... }:

let
  pnames = [
    "csvs-from-markdown-tables"
    "simple-markdown"
  ];
in
{
  overlays.pandoc = final: prev:
    let
      extras = {
      };
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
    packages.${system} = self.overlays.pandoc
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
