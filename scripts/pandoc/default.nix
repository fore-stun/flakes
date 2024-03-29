{ self, lib, nixpkgs, ... }:

let
  pnames = [
    "csvs-from-markdown-tables"
    "simple-markdown"
    "word-count"
  ];
in
{
  overlays.pandoc = final: prev:
    let
      extras = {
        simple-markdown = {
          lua = final.lua5_4;
        };
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
