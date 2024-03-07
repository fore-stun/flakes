{ self, lib, nixpkgs, spanx, ... }:

let
  pnames = [ "tailscale-nginx-auth" ];

  forAarch64Linux = pkgs: drv: (drv.override {
    inherit (pkgs.pkgsCross.aarch64-multiplatform-musl) hostPlatform;
    aarch64-linux = true;
  }).overrideAttrs (old: {
    GOOS = "linux";
    GOARCH = "arm64";
    CGO_ENABLED = false;
  });

in
{
  overlays.caddy = final: prev: lib.foldFor pnames (pname: {
    ${pname} = prev.callPackage (./. + "/${pname}.nix") { };
  });
} //
lib.foldFor lib.platforms.all (system:
  let pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    packages.${system} =
      lib.filterAttrs (_: lib.isDerivation) self.legacyPackages.${system} // {
        tailscale-nginx-auth-aarch64-linux =
          forAarch64Linux pkgs self.packages.${system}.tailscale-nginx-auth;
      };
    legacyPackages.${system} = self.overlays.caddy
      self.legacyPackages.${system}
      pkgs // {
      caddy-extended = let spanxPkgs = spanx.packages.${system}; in
        spanxPkgs.${system} or spanxPkgs.default;
    };
  })
