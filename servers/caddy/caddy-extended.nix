{ caddyWith
}:

caddyWith {
  plugins = {
    # Caddy dns
    "github.com/caddy-dns/cloudflare" = "89f16b99c18ef49c8bb470a82f895bce01cbaece";
    "github.com/caddy-dns/route53" = "94b571790e968b09916dc95cc521bc1c2327f7d1";

    "github.com/fore-stun/spanx" = "9e9109e6b964cd36fb9cb1be8328b0f32b3d60c3";
    "github.com/greenpau/caddy-security" = "90049c80f2c048dfc1d493c221b9f53a1dca43d5";
    "github.com/lindenlab/caddy-s3-proxy" = "850db193cb7f48546439d236f2a6de7bd7436e2e";
    "github.com/abiosoft/caddy-exec" = "521d8736cb4d1ce7f5b8bf8be6f3a2c9ecad843c";
  };
  vendorHash = "sha256-s8CGFHONXZlqDGnNZ8JCQmSk6DsApeARZShabOxB6nE=";
}
