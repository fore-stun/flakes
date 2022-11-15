{ self, lib, nixpkgs, ... }:

{
  overlays.sqlite = final: prev: {
    sqlite-extended = prev.callPackage ./package.nix {
      inherit (final) sqlitePlugins;
    };
    sqlitePlugins = prev.callPackage ./plugins.nix { };
  };
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
