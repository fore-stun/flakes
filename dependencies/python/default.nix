{ self, lib, nixpkgs, ... }:

let
  pnames = [ "yamldown" ];

  newPackages = final: prev: lib.foldFor pnames (pname: {
    ${pname} = prev.callPackage (./. + "/${pname}.nix") {
      inherit (final) python3Packages;
    };
  });

in
{
  overlays.python = final: prev: {
    python3 = prev.python3 // {
      pkgs = prev.python3.pkgs.overrideScope (lib.composeManyExtensions [
        (_: _: newPackages final prev)
      ]);
    };

    python3Packages = final.python3.pkgs;
  };

} //
lib.foldFor lib.platforms.all (system: {
  packages.${system} = self.overlays.python
    self.packages.${system}
    nixpkgs.legacyPackages.${system};
})
