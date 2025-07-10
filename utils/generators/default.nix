{ self, lib, nixpkgs, ... }:

let
  pnames = [ "an" "jwk-keygen" "names" "uuid" ];
in
{
  overlays.generators = final: prev:
    let
      extras = {
        an = {
          inherit (final) hunspellDicts;
        };
      };
    in
    lib.foldFor pnames (pname: {
      ${pname} = prev.callPackage
        (./. + "/${pname}.nix")
        (extras."${pname}" or { });
    });
} //
lib.foldFor lib.platforms.all (system: {
  packages.${system} = self.overlays.generators
    (nixpkgs.legacyPackages.${system} // self.packages.${system})
    nixpkgs.legacyPackages.${system};
})
