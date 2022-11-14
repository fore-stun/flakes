{ self, lib, nixpkgs, ... }:

lib.foldFor lib.platforms.all (system: {
  packages.${system} = {
    sqlite =
      nixpkgs.legacyPackages.${system}.callPackage ./package.nix {
        inherit (self.packages.${system}) sqlitePlugins;
      };
    sqlitePlugins =
      nixpkgs.legacyPackages.${system}.callPackage ./plugins.nix { };
  };

  apps.${system}.sqlite = {
    type = "app";
    program = self.packages.${system}.sqlite + "/bin/sqlite3";
  };
})
