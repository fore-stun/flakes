{ caddyWith
}:

caddyWith {
  plugins = {
    "github.com/fore-stun/spanx" = "9e9109e6b964cd36fb9cb1be8328b0f32b3d60c3";
    "github.com/greenpau/caddy-security" = "8d00b5c2ae849b997a9faad47fab9f92dfd77b08";
    "github.com/lindenlab/caddy-s3-proxy" = "850db193cb7f48546439d236f2a6de7bd7436e2e";
  };
  vendorHash = "sha256-y7iq9v2KDc5N5W4JRJtnVeG3CpjzlGAUYo3Qk0IkjFk=";
}
