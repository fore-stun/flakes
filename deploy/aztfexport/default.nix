{ self, lib, nixpkgs, ... }:

let
  pname = "aztfexport";
  systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
in
{
  overlays.${pname} = final: prev: {
    ${pname} = prev.callPackage ./package.nix { };
  };
} //
lib.foldFor systems (system: {
  packages.${system} = self.overlays.${pname}
    self.packages.${system}
    nixpkgs.legacyPackages.${system};
})
