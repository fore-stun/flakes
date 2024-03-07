{ caddyWith
, fetchXCaddy
}:

caddyWith {
  plugins = [
    "github.com/fore-stun/spanx"
    "github.com/greenpau/caddy-security"
    "github.com/lindenlab/caddy-s3-proxy"
  ];
  vendorHash = "sha256-y7iq9v2KDc5N5W4JRJtnVeG3CpjzlGAUYo3Qk0IkjFk=";
}
