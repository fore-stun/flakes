{ lib
, caddy
, buildGoModule
, fetchFromGitHub
}:

let
  rev = "cf5f5418d695a15e9888539e169fdd8dd64e0f77";

  src = fetchFromGitHub {
    name = "spanx-${rev}-src";
    owner = "fore-stun";
    repo = "spanx";
    inherit rev;
    hash = "sha256-mhUjtSpbIhpx6ghRK3EwiA7pkYeSePBULyOdpVQru3I=";
  };

in
(caddy.override ({
  buildGoModule = args: buildGoModule (args // {
    version = "2.6.4";
    vendorHash = "sha256-PV2K929Sum6qLF8JwDKzxITp6qy24QoToU9Oh0xU8fE=";
    inherit src;
  });
})).overrideAttrs
  (old: {
    meta = old.meta or { } // {
      mainProgram = "caddy";
    };
  })
