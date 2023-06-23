{ self, lib, nixpkgs, ... }:

let
  pnames = [ "pgperms" "storage-api" ];

  pgs = [ "" "_15" "_14" ];
in
{
  overlays.postgres = final: prev: lib.foldFor pgs
    (pg: {
      "postgresql${pg}" = prev."postgresql${pg}".overrideAttrs (old: {
        passthru = lib.recursiveUpdate old.passthru or { } {
          pkgs = prev.callPackage ./plugins.nix { postgresql = prev."postgresql${pg}"; };
        };
      });
    }) // lib.foldFor pnames
    (pname: {
      ${pname} = prev.callPackage (./. + "/${pname}.nix") { };
    });
} //
lib.foldFor lib.platforms.all (system: {
  packages.${system} = self.overlays.postgres
    self.packages.${system}
    nixpkgs.legacyPackages.${system};
})
