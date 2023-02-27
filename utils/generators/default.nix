{ self, lib, nixpkgs, ... }:

let
  pnames = [ "names" ];
in
{
  overlays.generators = final: prev: lib.foldFor pnames (pname: {
    ${pname} = prev.callPackage (./. + "/${pname}.nix") { };
  });
} //
lib.foldFor lib.platforms.all (system: {
  packages.${system} = self.overlays.generators
    self.packages.${system}
    nixpkgs.legacyPackages.${system};
})
