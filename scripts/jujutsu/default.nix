{ self, lib, nixpkgs, ... }:

let
  pnames = [
    "jj-scripts"
  ];
in
{
  overlays.jujutsu-script = final: prev: lib.foldFor pnames (pname: {
    ${pname} = prev.callPackage (./. + "/${pname}.nix") {
      inherit (final) writers;
      inherit lib;
    };
  });
} //
lib.foldFor lib.platforms.all (system:
  {
    packages.${system} = self.overlays.jujutsu-script
      self.legacyPackages.${system}
      nixpkgs.legacyPackages.${system};
  }
)
