{ self, lib, nixpkgs, ... }:

let
  pnames = [ "pgperms" ];
in
{
  overlays.postgres = final: prev: lib.foldFor pnames (pname: {
    ${pname} = prev.callPackage (./. + "/${pname}.nix") { };
  });
} //
lib.foldFor lib.platforms.all (system: {
  packages.${system} = self.overlays.postgres
    self.packages.${system}
    nixpkgs.legacyPackages.${system};
})
