{ self, lib, nixpkgs, ... }:

let
  pnames = [ ];
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

  apps.${system}.sqlite = {
    type = "app";
    program = self.packages.${system}.sqlite + "/bin/sqlite3";
  };
})
