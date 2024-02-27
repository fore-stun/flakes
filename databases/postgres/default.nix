{ self, lib, nixpkgs, ... }:

let
  pnames = [ "pgperms" "postgrest-bin" "storage-api" ];

  pgs = [ "" "_16" "_15" "_14" ];

in
{
  overlays.postgres = final: prev:
    let
      extras = {
        postgrest-bin = {
          postgresql = final.postgresql_16;
        };
      };

      pkgFor = pname: {
        ${pname} = prev.callPackage
          (./. + "/${pname}.nix")
          (extras."${pname}" or { });
      };
    in
    lib.foldFor pgs
      (pg: {
        "postgresql${pg}" = prev."postgresql${pg}".overrideAttrs (old: {
          passthru = lib.recursiveUpdate old.passthru or { } {
            pkgs = prev.callPackage ./plugins.nix { postgresql = prev."postgresql${pg}"; };
          };
        });
      }) // lib.foldFor pnames
      (pname:
        if lib.isString pname then pkgFor pname else
        lib.foldFor pname.systems
          (system: if system == prev.system then pkgFor pname else { })
      );
} //
lib.foldFor lib.platforms.all (system: {
  packages.${system} = self.overlays.postgres
    self.packages.${system}
    nixpkgs.legacyPackages.${system};
})
