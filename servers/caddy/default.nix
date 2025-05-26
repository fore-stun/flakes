{ self, lib, nixpkgs, ... }:

let
  pnames = [ "caddy-extended" "tailscale-nginx-auth" ];

  forAarch64Linux = pkgs: drv: (drv.override {
    inherit (pkgs.pkgsCross.aarch64-multiplatform-musl) stdenv;
    aarch64-linux = true;
  }).overrideAttrs (old: {
    GOOS = "linux";
    GOARCH = "arm64";
    CGO_ENABLED = false;
  });

in
{
  overlays.caddy = final: prev:
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
      lib.filterAttrs (_: lib.isDerivation) self.legacyPackages.${system} // {
        tailscale-nginx-auth-aarch64-linux =
          forAarch64Linux pkgs self.packages.${system}.tailscale-nginx-auth;
      };
    legacyPackages.${system} = self.overlays.caddy
      self.legacyPackages.${system}
      pkgs;
  })
