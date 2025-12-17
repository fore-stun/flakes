{ self, lib, nixpkgs, ... }:

let
  pnames = [ "pgperms" "postgrest-bin" "sqldiff" "storage-api" ];

  pgs = [ "" "_17" "_16" "_15" "_14" ];

in
{
  overlays.postgres = final: prev:
    let
      extras = {
        postgrest-bin = {
          postgresql = final.postgresql_17;
        };
        sqldiff = {
          inherit (final) writers;
          inherit lib;
        };
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
      (pname: {
        ${pname} = prev.callPackage
          (./. + "/${pname}.nix")
          (extras."${pname}" or { });
      });
} //
lib.foldFor lib.platforms.all (system:
  let
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    packages.${system} =
      lib.filterAttrs (_: lib.isDerivation) self.legacyPackages.${system};
    legacyPackages.${system} = self.overlays.postgres
      (pkgs // self.legacyPackages.${system})
      pkgs;
  })
