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
lib.foldFor lib.platforms.all (system:
  let
    pkgs = self.overlays.sqlite
      self.legacyPackages.${system}
      nixpkgs.legacyPackages.${system};
  in
  {
    checks.${system}.plugins = lib.callPackageWith
      (nixpkgs.legacyPackages.${system} // pkgs)
      ./test/plugins.nix
      { };
    legacyPackages.${system} = pkgs;
    packages.${system} = lib.filterAttrs (_: a: lib.isDerivation a) pkgs;
  })
