{ caddy
}:

caddy.withPlugins {
  plugins = [
    # Caddy dns
    "github.com/caddy-dns/cloudflare@v0.2.2"
    "github.com/fore-stun/libdns-route53@v0.0.0-20250526213255-7a723d8255bf"

    "github.com/fore-stun/spanx@v0.0.0-20250507102219-58d4b8a0d7f3"
    "github.com/fore-stun/caddy-s3-proxy@v0.5.7-0.20250526214057-c90e95199238"
    "github.com/abiosoft/caddy-hmac@v0.0.0-20210522205451-976ca0a419ef"
    "github.com/abiosoft/caddy-exec@v0.0.0-20240914124740-521d8736cb4d"
    "github.com/abiosoft/caddy-inspect@v0.0.0-20250214103948-96cdb1dfb122"
    "github.com/ggicci/caddy-jwt@v0.12.0"
  ];
  hash = "sha256-afTlnnjx9QLVHXOsUFen02Yg42bLx6B76kb3jRj9kgk=";
}
