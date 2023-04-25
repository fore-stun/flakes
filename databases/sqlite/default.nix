{ self, lib, nixpkgs, ... }:

let
  pnames = [ "markdown-to-sqlite" "sqlitebiter" ];
in
{
  overlays.sqlite = final: prev: {
    sqlite-extended = prev.callPackage ./package.nix {
      inherit (final) sqlitePlugins;
    };
    sqlitePlugins = prev.sqlitePlugins or { }
    // prev.callPackage ./plugins.nix { };
  } // lib.foldFor pnames (pname: {
    ${pname} = prev.callPackage (./. + "/${pname}.nix") {
      inherit (final) python3Packages;
    };
  });
} //
lib.foldFor lib.platforms.all (system: {
  packages.${system} = self.overlays.sqlite
    self.packages.${system}
    nixpkgs.legacyPackages.${system};
})
