{ lib
, darwin
, dockerTools
, hostPlatform
, jq
, postgresql
, postgrest
, stdenvNoCC
, zlib
}:

let

  inherit (postgrest) pname meta;
  version = "12.0.2";

  src = (dockerTools.pullImage {
    imageName = "ghcr.io/homebrew/core/postgrest";
    imageDigest = "sha256:288cc99f15025e5057898a0f00f91e4a7dbe991cebf3ffa92bc4d1bb9155e179";
    sha256 = "sha256-zqX1psQwKQH5Sy5b7PohGbMpLlw2pG4kj0reNVzv0mU=";
    finalImageName = "postgrest/postgrest";
    finalImageTag = version;
    os = "darwin/macos";
    arch = "arm64";
  }).overrideAttrs (old: {
    buildCommand = builtins.replaceStrings [ "--src-tls-verify" ] [ "--tls-verify" ] old.buildCommand;
  });

  postgrestBin = stdenvNoCC.mkDerivation {
    inherit pname src version;
    meta = meta // {
      license = lib.licenses.mit;
      platforms = [ "aarch64-darwin" ];
    };
    outputs = [ "out" "bin" ];

    SRC_BIN = "postgrest/${version}/bin/postgrest";

    nativeBuildInputs = [
      jq
    ];

    buildInputs = [
      darwin.libiconv
      postgresql.lib
      zlib
    ];

    dontUnpack = true;

    buildPhase = ''
      tar --extract --wildcards --to-stdout -f "$src" 'manifest.json' \
        | jq -r '.[0] | .Layers | last' \
        | xargs -I {} tar --extract --to-stdout -f "$src" {} \
        | tar -xv "$SRC_BIN"

      mkdir -p "$bin"
      mv "$SRC_BIN" "$bin/postgrest"
    '';

    postFixup = lib.optionalString hostPlatform.isDarwin ''
      /usr/bin/install_name_tool -change "/usr/lib/libz.1.dylib" "${zlib}/lib/libz.1.dylib" "$bin/postgrest"
      /usr/bin/install_name_tool -change "@@HOMEBREW_PREFIX@@/opt/libpq/lib/libpq.5.dylib" "${postgresql.lib}/lib/libpq.5.dylib" "$bin/postgrest"
      /usr/bin/install_name_tool -change "/usr/lib/libiconv.2.dylib" "${darwin.libiconv}/lib/libiconv.2.dylib" "$bin/postgrest"
      /usr/bin/install_name_tool -change "/usr/lib/libcharset.1.dylib" "${darwin.libiconv}/lib/libcharset.1.dylib" "$bin/postgrest"

      /usr/bin/codesign --force -s - "$bin/postgrest"
    '';
  };

in
postgrestBin
