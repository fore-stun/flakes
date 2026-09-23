{ self, lib, nixpkgs, ... }:

let
  pnames = [ "telnyx-cli" "telnyx-edge" ];

in
{
  overlays.telnyx = final: prev:
    let
      extras = { };
    in
    lib.foldFor pnames (pname: {
      ${pname} =
        lib.callPackageWith prev (./. + "/${pname}.nix") (extras.${pname} or { });
    });
} //
lib.foldFor lib.platforms.all (system:
  let
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    packages.${system} =
      lib.filterAttrs (_: lib.isDerivation) self.legacyPackages.${system};
    legacyPackages.${system} = self.overlays.telnyx
      self.legacyPackages.${system}
      pkgs;
  })
