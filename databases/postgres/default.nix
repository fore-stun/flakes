{ self, lib, nixpkgs, ... }:

let
  pnames = [ "pgperms" "storage-api" ];
in
{
  overlays.postgres = final: prev: {
    postgresql = prev.postgresql.overrideAttrs (old: {
      passthru = lib.recursiveUpdate old.passthru or { } {
        pkgs = prev.callPackage ./plugins.nix { };
      };
    });
  } // lib.foldFor pnames
    (pname: {
      ${pname} = prev.callPackage (./. + "/${pname}.nix") { };
    });
} //
lib.foldFor lib.platforms.all (system: {
  packages.${system} = self.overlays.postgres
    self.packages.${system}
    nixpkgs.legacyPackages.${system};
})
