{ lib
, buildGoModule
, fetchFromGitHub
, hostPlatform
, aarch64-linux ? false
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

  preInstall = lib.optionalString aarch64-linux ''
    mkdir -p "$out/bin"
    dir="$GOPATH/bin"
    [ -e "$dir" ] && mv -v "$dir/linux_arm64/"* "$dir/"
    rm -rv "$dir/linux_arm64/"
  '';

  postInstall = lib.optionalString hostPlatform.isLinux ''
    mkdir -p "$out/lib/systemd/system"

    install -D -m0444 -t "$out/lib/systemd/system" \
      "$src/cmd/nginx-auth/tailscale.nginx-auth.service"
    install -D -m0444 -t "$out/lib/systemd/system" \
      "$src/cmd/nginx-auth/tailscale.nginx-auth.socket"

    sed -i -e "s#/usr/sbin#$out/bin#" "$out/lib/systemd/system/tailscale.nginx-auth.service"
    sed -i -e "s#/var/run/#/run/#" "$out/lib/systemd/system/tailscale.nginx-auth.socket"
  '' + lib.optionalString hostPlatform.isDarwin ''
    mkdir -p "$out/Library/LaunchAgents"
    cp ${./tailscale-nginx-auth.plist} "$out/Library/LaunchAgents/org.nixos.tailscale.nginx-auth.plist"
    substituteInPlace $out/Library/LaunchAgents/org.nixos.tailscale.nginx-auth.plist --subst-var out
  '' + ''
    for i in "$out/bin/"*; do
      ln -sv "$i" "$out/bin/tailscale.''${i##*/}"
    done
  '';

  meta = {
    description = "Use Tailscale Whois authentication with NGINX/Caddy as a reverse proxy";
    license = lib.licenses.bsd3;
    mainProgram = pname;
  };
}
