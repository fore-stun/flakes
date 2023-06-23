{ lib
, callPackage
, fetchFromGitHub
, postgresql
}:

let
  pg_uuidv7 = { lib, stdenv, postgresql }:
    let
      pname = "pg_uuidv7";
      version = "1.0.1";

      src = fetchFromGitHub {
        name = "${pname}-${version}-src";
        repo = pname;
        owner = "fboulnois";
        rev = "486b1011ece3c7ad846aa9595042b5e12f4629d8";
        hash = "sha256-/LIbyFq0QGbGAsDSLyaT6/f5LUaCphp087NqAwHDytU=";
      };
    in
    stdenv.mkDerivation {
      inherit pname version src;

      buildInputs = [ postgresql ];

      installPhase = ''
        install -D -t "$out/lib" *.so
        install -D -t "$out/share/postgresql/extension" *.sql
        install -D -t "$out/share/postgresql/extension" *.control
      '';

      meta = {
        description = "A tiny Postgres extension to create version 7 UUIDs";
        homepage = "https://github.com/fboulnois/pg_uuidv7";
        inherit (postgresql.meta) platforms;
        license = lib.licenses.mpl20;
      };
    };

in
lib.mapAttrs (n: f: callPackage f { inherit postgresql; }) {
  inherit
    pg_uuidv7
    ;
}
