{ self, lib, nixpkgs, ... }:

let
  pnames = [ ];

  newPackages = final: prev: lib.foldFor pnames (pname: {
    ${pname} = prev.callPackage (./. + "/${pname}.nix") {
      inherit (final) python3Packages;
    };
  });

in
{
  overlays.python = final: prev: {
    python3 = prev.python3.override {
      packageOverrides = lib.composeManyExtensions [
        (_: _: newPackages final prev)
      ];
    };

    python3Packages = final.python3.pkgs;
  };

} //
lib.foldFor lib.platforms.all (system: {
  packages.${system} = self.overlays.python
    self.packages.${system}
    nixpkgs.legacyPackages.${system};
})
