{ self, lib, nixpkgs, ... }:

let
  pnames = [ ];

in
{
  overlays.go-script = final: prev:
    let
      extras = { };
    in
    lib.foldFor pnames (pname: {
      ${pname} =
        lib.callPackageWith prev (./. + "/${pname}.nix") (
          extras.${pname} or {
            inherit (final) writers;
            inherit lib;
          }
        );
    });
} //
lib.foldFor lib.platforms.all (system:
  let
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    packages.${system} =
      lib.filterAttrs (_: lib.isDerivation) self.legacyPackages.${system} // { };
    legacyPackages.${system} = self.overlays.go-script
      self.legacyPackages.${system}
      pkgs;
  })
