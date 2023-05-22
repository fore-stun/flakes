{ self, lib, nixpkgs, ... }:

let
  pnames = [ "deno_bindgen" ];
in
{
  overlays.deno-bindgen = final: prev: lib.foldFor pnames (pname: {
    ${pname} = prev.callPackage (./. + "/${pname}.nix") { };
  });
} //
lib.foldFor lib.platforms.all (system: {
  packages.${system} = self.overlays.deno-bindgen
    self.packages.${system}
    nixpkgs.legacyPackages.${system};
})
