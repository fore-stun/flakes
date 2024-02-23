{ self, lib, nixpkgs, ... }:

let
  pnames = [ "pgperms" "storage-api" ];

  pgs = [ "" "_16" "_15" "_14" ];

in
{
  overlays.postgres = final: prev:
    let
      extras = {
        postgrest = {
          postgrestMeta = prev.postgrest.meta;
          postgresql = prev.postgresql_16;
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
      }) // lib.optionalAttrs (prev.hostPlatform.isAarch64 && prev.hostPlatform.isDarwin) {
      postgrest = prev.callPackage ./postgrest.nix extras.postgrest;
    };
} //
lib.foldFor lib.platforms.all (system: {
  packages.${system} = self.overlays.postgres
    self.packages.${system}
    nixpkgs.legacyPackages.${system};
})
