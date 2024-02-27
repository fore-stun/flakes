{ self, lib, nixpkgs, ... }:

let
  pnames = [ "jkparse" ];
in
{
  overlays.shell = final: prev: lib.foldFor pnames (pname: {
    ${pname} = prev.callPackage (./. + "/${pname}.nix") { };
  });
} //
lib.foldFor lib.platforms.all (system: {
  packages.${system} = self.overlays.shell
    self.packages.${system}
    nixpkgs.legacyPackages.${system};
})
