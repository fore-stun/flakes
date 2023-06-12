{ self, lib, nixpkgs, ... }:

let
  pnames = [ "caddy-extended" "tailscale-nginx-auth" ];
in
{
  overlays.caddy = final: prev: lib.foldFor pnames (pname: {
    ${pname} = prev.callPackage (./. + "/${pname}.nix") { };
  });
} //
lib.foldFor lib.platforms.all (system: {
  packages.${system} = self.overlays.caddy
    self.packages.${system}
    nixpkgs.legacyPackages.${system};
})
