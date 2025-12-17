{ lib
, callPackage
, fetchFromGitHub
, postgresql
, stdenv
}:

let
  usePlatformExtension = (stdenv.hostPlatform.isDarwin && postgresql.psqlSchema >= "16");

  setDLSUFFIX = old: {
    buildFlags = old.buildFlags or [ ] ++ [ ''DLSUFFIX=".so"'' ];
  };

in
lib.optionalAttrs usePlatformExtension
  (lib.mapAttrs (n: a: a.overrideAttrs setDLSUFFIX) postgresql.passthru.pkgs)
  //
lib.mapAttrs (n: f: callPackage f { inherit postgresql; }) { }
