{ self, lib, nixpkgs, ... }:

let
  pnames = [ "writePythonBin" "writeZshBin" ];
in
{
  overlays.writers = final: prev: lib.foldFor pnames (pname: {
    writers.${pname} = prev.callPackage (./. + "/${pname}.nix") { };
  });
} //
lib.foldFor lib.platforms.all (system: {
  packages.${system} = self.overlays.writers
    self.packages.${system}
    nixpkgs.legacyPackages.${system};
})
