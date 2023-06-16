{ self, lib, nixpkgs, ... }:

let
  pnames = [ "nswag" ];
in
{
  overlays.dotnet = final: prev: lib.foldFor pnames (pname: {
    ${pname} = prev.callPackage (./. + "/${pname}.nix") { };
  });
} //
lib.foldFor lib.platforms.all (system: {
  packages.${system} = self.overlays.dotnet
    self.packages.${system}
    nixpkgs.legacyPackages.${system};
})
