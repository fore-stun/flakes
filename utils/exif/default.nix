{ self, lib, nixpkgs, ... }:

let
  pnames = [ "exif-copy" ];
in
{
  overlays.exif = final: prev: lib.foldFor pnames (pname: {
    ${pname} = prev.callPackage (./. + "/${pname}.nix") {
      inherit (final) writers;
      inherit lib;
    };
  });
} //
lib.foldFor lib.platforms.all (system: {
  packages.${system} = self.overlays.exif
    self.packages.${system}
    nixpkgs.legacyPackages.${system};
})
