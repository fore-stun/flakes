{ self, lib, nixpkgs, ... }:

let
  pnames = [ "mount-interactive" ];
in
{
  overlays.system-script = final: prev: lib.foldFor pnames
    (pname: {
      ${pname} = prev.callPackage (./. + "/${pname}.nix") {
        inherit (final) writers;
        inherit lib;
      };
    });
} //
lib.foldFor lib.platforms.all (system: {
  packages.${system} = self.overlays.system-script
    self.legacyPackages.${system}
    nixpkgs.legacyPackages.${system};
})
