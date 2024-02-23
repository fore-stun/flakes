{ self, lib, nixpkgs, ... }:

let
  pnames = [ "prettier-plugin-svelte" ];
in
{
  overlays.formetter = final: prev: lib.foldFor pnames (pname: {
    ${pname} = prev.callPackage (./. + "/${pname}.nix") { };
  });
} //
lib.foldFor lib.platforms.all (system: {
  packages.${system} = self.overlays.formetter
    self.packages.${system}
    nixpkgs.legacyPackages.${system};
})
