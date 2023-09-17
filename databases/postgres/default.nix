{ self, lib, nixpkgs, postgrest, ... }:

let
  pnames = [ "pgperms" "postgrest" "storage-api" ];

  pgs = [ "" "_15" "_14" ];

  extras = {
    postgrest = { inherit postgrest; };
  };
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
      ${pname} = prev.callPackage
        (./. + "/${pname}.nix")
        (extras."${pname}" or { });
    });
} //
lib.foldFor lib.platforms.all (system: {
  packages.${system} = self.overlays.postgres
    self.packages.${system}
    nixpkgs.legacyPackages.${system};
})
