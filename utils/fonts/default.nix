{ self, lib, nixpkgs, ... }:

let
  pnames = [ "gfcli" "glyphhanger" ];
in
{
  overlays.fonts = final: prev: lib.foldFor pnames (pname: {
    ${pname} = prev.callPackage (./. + "/${pname}.nix") {
      inherit lib;
    };
  });
} //
lib.foldFor lib.platforms.all (system:
  let
    pkgs = self.overlays.fonts
      self.legacyPackages.${system}
      nixpkgs.legacyPackages.${system};
  in
  {
    legacyPackages.${system} = pkgs;
    packages.${system} = lib.filterAttrs (_: a: lib.isDerivation a) pkgs;
  })
