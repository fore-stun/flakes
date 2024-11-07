{ self, lib, nixpkgs, ... }:

let
  pnames = [ "eml2html" "css-inline" ];
in
{
  overlays.email = final: prev: lib.foldFor pnames (pname: {
    ${pname} = prev.callPackage (./. + "/${pname}.nix") { };
  });
} //
lib.foldFor lib.platforms.all (system: {
  packages.${system} = self.overlays.email
    self.packages.${system}
    nixpkgs.legacyPackages.${system};
})
