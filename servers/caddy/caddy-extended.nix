{ caddy
}:

caddy.withPlugins {
  plugins = [
    # Caddy dns
    "github.com/caddy-dns/cloudflare@89f16b99c18ef49c8bb470a82f895bce01cbaece"
    "github.com/caddy-dns/route53@94b571790e968b09916dc95cc521bc1c2327f7d1"

    "github.com/fore-stun/spanx@9e9109e6b964cd36fb9cb1be8328b0f32b3d60c3"
    "github.com/lindenlab/caddy-s3-proxy@850db193cb7f48546439d236f2a6de7bd7436e2e"
    "github.com/abiosoft/caddy-exec@521d8736cb4d1ce7f5b8bf8be6f3a2c9ecad843c"
    "github.com/abiosoft/caddy-hmac@976ca0a419efb59fcbd8f32072132779e9d9a5c0"
    "github.com/abiosoft/caddy-inspect@96cdb1dfb122f79913d60ecb34030d302a4f4ec1"
    "github.com/ggicci/caddy-jwt@baeab7ec43c49fe77caa18b8bb16739b3276e356"
  ];
  hash = "sha256-fWS/DdkOcdsrRqEuh0Xlb5/PmhWd/daD1CCb5S7bHWU=";


}
