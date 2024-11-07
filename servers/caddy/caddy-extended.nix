{ caddyWith
}:

caddyWith {
  plugins = {
    # Caddy dns
    "github.com/caddy-dns/cloudflare" = "89f16b99c18ef49c8bb470a82f895bce01cbaece";
    "github.com/caddy-dns/route53" = "d92230e22b716e9b0c8bc1086477415f8b90e77f";

    "github.com/fore-stun/spanx" = "9e9109e6b964cd36fb9cb1be8328b0f32b3d60c3";
    "github.com/greenpau/caddy-security" = "bdd7abe375e7b0c13e6233a2f9b5433ba69c6af9";
    "github.com/lindenlab/caddy-s3-proxy" = "850db193cb7f48546439d236f2a6de7bd7436e2e";
  };
  vendorHash = "sha256-NKrunCIgwCny8h0bGOtvIv1R/2f1s1/C5sgCPaLkjkU=";
}
