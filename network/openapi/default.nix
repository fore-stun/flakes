{ self, lib, nixpkgs, ... }:

let
  pnames = [ "cargo-progenitor" ];
in
{
  overlays.openapi = final: prev:
    let
      extras = { };
    in
    lib.foldFor pnames (pname: {
      ${pname} = prev.callPackage
        (./. + "/${pname}.nix")
        (extras."${pname}" or { });
    });
} //
lib.foldFor lib.platforms.all (system: {
  packages.${system} = self.overlays.openapi
    (nixpkgs.legacyPackages.${system} // self.packages.${system})
    nixpkgs.legacyPackages.${system};
})
