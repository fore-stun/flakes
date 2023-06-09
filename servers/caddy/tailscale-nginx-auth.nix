{ lib
, buildGoModule
, fetchFromGitHub
}:

let
  pname = "tailscale-nginx-auth";
  version = "0.1.0";
  src = fetchFromGitHub {
    name = "${pname}-${version}-src";
    owner = "tailscale";
    repo = "tailscale";
    rev = "a353ae079b8b0c5205278585c8c0a42ba00185a6";
    hash = "sha256-OntCgV5vQig5neCaKvKXJKK1FiwcmrdilE+qTdsVn1I=";
  };
in
buildGoModule {
  inherit pname version src;

  subPackages = [ "cmd/nginx-auth" ];

  vendorHash = "sha256-l2uIma2oEdSN0zVo9BOFJF2gC3S60vXwTLVadv8yQPo=";

  patches = [
    (builtins.path {
      name = "${pname}.patch";
      path = ./${pname}.patch;
    })
  ];

  CGO_ENABLED = 0;
  doCheck = false;

  meta = {
    description = "Use Tailscale Whois authentication with NGINX/Caddy as a reverse proxy";
    license = lib.licenses.bsd3;
  };
}
