{ self, lib, nixpkgs, ... }:

let
  pnames = [
    "cf-kv-local"
    "markdown-to-sqlite"
    "sqlitebiter"
    "xlite"
  ];
in
{
  overlays.sqlite = final: prev:
    let
      extras = {
        cf-kv-local = { inherit lib; inherit (final) writers; };
        markdown-to-sqlite = { inherit (final) python3Packages; };
        sqlitebiter = { inherit (final) python3Packages; };
      };
    in
    {
      sqlite-extended = prev.callPackage ./package.nix {
        inherit (final) sqlitePlugins;
      };
      sqlitePlugins = prev.sqlitePlugins or { }
      // prev.callPackage ./plugins.nix {
        inherit (final) xlite;
      };
    } // lib.foldFor pnames (pname: {
      ${pname} = prev.callPackage
        (./. + "/${pname}.nix")
        (extras."${pname}" or { });
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
