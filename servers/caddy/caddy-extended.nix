{ lib
, caddy
, buildGoModule
}:

(caddy.override ({
  buildGoModule = args: buildGoModule (args // {
    vendorHash = "sha256-J6wIbJ+7R33gwjCuERjZm387jGcTrIy6709aChjZezY=";
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
