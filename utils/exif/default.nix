{ self, lib, nixpkgs, ... }:

let
  pnames = [ ];
in
{
  overlays.exif = final: prev: lib.foldFor pnames (pname: {
    ${pname} = prev.callPackage (./. + "/${pname}.nix") { };
  });
} //
lib.foldFor lib.platforms.all (system: {
  packages.${system} = self.overlays.exif
    self.packages.${system}
    nixpkgs.legacyPackages.${system};
})
