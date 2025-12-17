{ lib
, tailscale-nginx-auth
, stdenv
, aarch64-linux ? false
}:

let
  pname = "tailscale-nginx-auth";

  overriding = old: {
    patches = [
      (builtins.path {
        name = "${pname}.patch";
        path = ./${pname}.patch;
      })
    ];

    preInstall = lib.optionalString aarch64-linux ''
      mkdir -p "$out/bin"
      dir="$GOPATH/bin"
      [ -e "$dir" ] && mv -v "$dir/linux_arm64/"* "$dir/"
      rm -rv "$dir/linux_arm64/"
    '';

    postInstall = lib.optionalString stdenv.hostPlatform.isLinux ''
      mkdir -p "$out/lib/systemd/system"

      install -D -m0444 -t "$out/lib/systemd/system" \
        "$src/cmd/nginx-auth/tailscale.nginx-auth.service"
      install -D -m0444 -t "$out/lib/systemd/system" \
        "$src/cmd/nginx-auth/tailscale.nginx-auth.socket"

      sed -i -e "s#/usr/sbin#$out/bin#" "$out/lib/systemd/system/tailscale.nginx-auth.service"
      sed -i -e "s#/var/run/#/run/#" "$out/lib/systemd/system/tailscale.nginx-auth.socket"
    '' + lib.optionalString stdenv.hostPlatform.isDarwin ''
      mkdir -p "$out/Library/LaunchAgents"
      cp ${./tailscale-nginx-auth.plist} "$out/Library/LaunchAgents/org.nixos.tailscale.nginx-auth.plist"
      substituteInPlace $out/Library/LaunchAgents/org.nixos.tailscale.nginx-auth.plist --subst-var out
    '' + ''
      for i in "$out/bin/"*; do
        ln -sv "$i" "$out/bin/tailscale.''${i##*/}"
      done
    '';

    env = old.env // lib.optionalAttrs aarch64-linux {
      GOOS = "linux";
      GOARCH = "arm64";
      CGO_ENABLED = false;
    };
  };
in
tailscale-nginx-auth.overrideAttrs overriding
