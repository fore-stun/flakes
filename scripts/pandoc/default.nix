{ self, lib, nixpkgs, ... }:

let
  pnames = [
    "csvs-from-markdown-tables"
    "json-from-markdown-tables"
    "simple-markdown"
  ];
in
{
  overlays.pandoc = final: prev:
    let
      extras = {
        simple-markdown = {
          lua = final.lua5_4;
        };
        csvs-from-markdown-tables = {
          inherit (final) json-from-markdown-tables;
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
    legacyPackages.${system} = self.overlays.pandoc
      self.legacyPackages.${system}
      nixpkgs.legacyPackages.${system};
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
