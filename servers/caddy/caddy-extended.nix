{ lib
, caddy
, buildGoModule
}:

(caddy.override ({
  buildGoModule = args: buildGoModule (args // {
    vendorHash = "sha256-M1VpxNQ1G4BOD/lmciiL1qylUKjrnucpi6LBfIi1+MY=";
    patches = [
      (builtins.path {
        name = "caddy.patch";
        path = ./caddy.patch;
      })
    ];
  });
})).overrideAttrs
  (old: {
    meta = old.meta or { } // {
      mainProgram = "caddy";
    };
  })
