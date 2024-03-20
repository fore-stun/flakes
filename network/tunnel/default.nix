{ self, lib, nixpkgs, crane, ... }:

let
  pnames = [
    "wstunnel"
  ];

in
{
  overlays.tunnel = final: prev:
    let
      extras = {
        wstunnel = { inherit crane; };
      };
    in
    lib.foldFor pnames (pname: {
      ${pname} = lib.callPackageWith prev (./. + "/${pname}.nix") (
        extras.${pname} or { }
      );
    });
} //
lib.foldFor lib.platforms.all (system: {
  packages.${system} = lib.flip lib.filterAttrs self.legacyPackages.${system}
    (n: a: builtins.elem n pnames && lib.isDerivation a);
  legacyPackages.${system} = self.overlays.tunnel
    self.legacyPackages.${system}
    nixpkgs.legacyPackages.${system};
})


