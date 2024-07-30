{ lib
, buildGoModule
, caddy
, fetchXCaddy
}:

lib.fix (caddyWith:
{ plugins
, vendorHash
}:
(
  caddy.override {
    buildGoModule = args: buildGoModule (args // {
      src = fetchXCaddy {
        inherit plugins;
        hash = vendorHash;
      };

      subPackages = [ "." ];
      ldflags = [ "-s" "-w" ]; ## don't include version info twice
      vendorHash = null;
    });
  }).overrideAttrs (old: {
  passthru = old.passthru or { } // {
    inherit caddyWith fetchXCaddy;
  };
}))
