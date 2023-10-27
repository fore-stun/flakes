{ self, lib, nixpkgs, ... }:

let
  pnames = [ ];
in
{
  overlays.postman = final: prev: lib.foldFor pnames (pname: {
    ${pname} = prev.callPackage (./. + "/${pname}.nix") {
      inherit lib;
    };
  });
} //
lib.foldFor lib.platforms.all (system: {
  packages.${system} = self.overlays.postman
    self.packages.${system}
    nixpkgs.legacyPackages.${system};
})
