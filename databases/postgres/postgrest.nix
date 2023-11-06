{ lib
, dockerTools
, glibc
, gmp
, haskellPackages
, hostPlatform
, jq
, keyutils
, krb5
, openssl
, postgresql
, postgrest
, stdenvNoCC
, system
, zlib
}:

let

  inherit (haskellPackages.postgrest) pname meta;
  version = "11.2.1";
  repository = "postgrest";

  src = dockerTools.pullImage {
    imageName = "postgrest/postgrest";
    imageDigest = "sha256:6feebe08e6afa576c4d6ef47f25557145ca82ccc543b443da37a26fb13d83821";
    sha256 = "1ha1iyiwf5asqpn0zk67fs2nbq0a3d3f0f0xj6nim84fq6xjdcnl";
    finalImageName = "postgrest/postgrest";
    finalImageTag = "v11.2.1-arm";
  };

  RPATH_INPUTS = [
    zlib
    gmp
    postgresql.lib
  ];

  postgrestBin = stdenvNoCC.mkDerivation {
    inherit pname src version;
    meta = meta // {
      license = lib.licenses.mit;
    };

    inherit RPATH_INPUTS;

    nativeBuildInputs = [
      jq
    ];

    buildInputs = RPATH_INPUTS ++ [
      glibc
      keyutils.lib
      krb5
      openssl.out
    ];

    dontUnpack = true;

    buildPhase = ''
      tar --extract --wildcards --to-stdout -f "$src" 'manifest.json' \
        | jq -r '.[0] | .Layers | last' \
        | xargs -I {} tar --extract --to-stdout -f "$src" {} \
        | tar -xv usr/bin/postgrest

      mkdir -p "$out/bin"
      mv usr/bin/postgrest "$out/bin/postgrest"
    '';

    postFixup = ''
      for i in ''${RPATH_INPUTS[@]}; do
        echo "Patching for $i" >&2
        patchelf --add-rpath "$i/lib" "$out/bin/postgrest"
        patchelf --print-rpath "$out/bin/postgrest"
      done
      patchelf --set-interpreter "${glibc.bin}/bin/ld.so" "$out/bin/postgrest"
    '';
  };

in
if hostPlatform.isAarch64 && hostPlatform.isLinux
then postgrestBin
else postgrest.packages."${system}".default
