{ lib
, caddy
, buildGoModule
}:

(caddy.override ({
  buildGoModule = args: buildGoModule (args // {
    vendorHash = "sha256-r/LyDJ9cVcKzAMQc+EocdKoDc1FVGbjcFrEs9KLvv/g=";
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
