{ self, lib, nixpkgs, ... }:

let
  pnames = [ "writeLuaBin" "writePythonBin" "writeZshBin" ];
in
{
  overlays.writers = final: prev: {
    writers = prev.writers or { } // lib.foldFor pnames (pname: {
      ${pname} = prev.callPackage (./. + "/${pname}.nix") { };
    });
  };
} //
lib.foldFor lib.platforms.all (system: {
  legacyPackages.${system} = self.overlays.writers
    self.legacyPackages.${system}
    nixpkgs.legacyPackages.${system};
})
