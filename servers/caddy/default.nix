{ self, lib, nixpkgs, ... }:

let
  pnames = [ "caddy-extended" ];

in
{
  overlays.caddy = final: prev:
    let
      fetchXCaddy = prev.callPackage ./fetchXCaddy.nix { };
      caddyWith = prev.callPackage ./caddyWith.nix {
        inherit fetchXCaddy;
      };
      extras = { caddy-extended = { inherit caddyWith; }; };
    in
    lib.foldFor pnames (pname: {
      ${pname} =
        prev.callPackage (./. + "/${pname}.nix") (extras.${pname} or { });
    });
} //
lib.foldFor lib.platforms.all (system:
  let
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    packages.${system} =
      lib.filterAttrs (_: lib.isDerivation) self.legacyPackages.${system};
    legacyPackages.${system} = self.overlays.caddy
      self.legacyPackages.${system}
      pkgs;
  })
