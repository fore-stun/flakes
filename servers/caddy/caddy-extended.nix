{ lib
, caddy
, buildGoModule
}:

(caddy.override ({
  buildGoModule = args: buildGoModule (args // {
    vendorHash = "sha256-Hb2UGHizbOU6AL55zSjWfpC4txpm9lSHfh4lHeer2c8=";
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
