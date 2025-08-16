{ self, lib, nixpkgs, ... }:

let
  pnames = [ "handbrake-bin" "handbrake-cli-bin" "handbrake-gui-bin" ];
in
{
  overlays.video = final: prev:
    let
      extras = {
        "handbrake-bin" = {
          inherit (final) handbrake-cli-bin handbrake-gui-bin;
        };
      };
    in
    lib.foldFor pnames
      (pname: {
        ${pname} = prev.callPackage
          (./. + "/${pname}.nix")
          (extras."${pname}" or { });
      });
} //
lib.foldFor lib.platforms.all (system:
  let
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    packages.${system} =
      lib.filterAttrs (_: lib.isDerivation) self.legacyPackages.${system};
    legacyPackages.${system} = self.overlays.video
      (pkgs // self.legacyPackages.${system})
      pkgs;
  })
