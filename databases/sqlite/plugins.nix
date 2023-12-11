{ lib
, callPackage
, fetchFromGitHub
, fetchzip
}:

let
  mkSqliteExt =
    { name
    , version
    , src
    , sourceFiles # relative to $src
    , outName ? name
    }:

    { lib
    , sqlite
    , stdenv
    }:
    let
      outFile = "${outName}.${if stdenv.isDarwin then "dylib" else "so"}";

      EXT_DIR = "lib/sqlite/ext/";
    in
    stdenv.mkDerivation {
      pname = "sqlite-${name}";
      inherit version src;

      dontConfigure = true;

      SOURCES = sourceFiles;
      inherit EXT_DIR;

      passthru = {
        # Consumers need to know the actual output file
        libPath = "${EXT_DIR}${outFile}";
      };

      buildPhase = ''
        "$CC" -v -g -fPIC ${if stdenv.isDarwin then "-dynamiclib" else "-shared"} \
          -I"${sqlite.dev}/include" \
          "''${SOURCES[@]}" \
          -o ${outFile}
      '';

      installPhase = ''
        local INSTALL_DIR="$out/$EXT_DIR"
        mkdir -p "$INSTALL_DIR"
        cp ${outFile} "$INSTALL_DIR"
      '';
    };

  bundled =
    let
      hashes = {
        "3.39.3" = "sha256-DkF8tP5Tbg40ZLsFqY7xYndhyFeF4H8N3WMb/HVaptk=";
        "3.40.1" = "sha256-Oye/JeXKVflfWxUq3OU3JG+wR0DDZw6GdvyJS3OGjFI=";
        "3.41.2" = "sha256-OKvBvk0vtgvOgds6MpiKFeKjezk2gp6lBKP6BdANGOc=";
        "3.42.0" = "sha256-IPNn0kN/dvIwJQRqD7B3aDkGYenic69QKa6NUDHZuu8=";
        "3.43.2" = "sha256-selyWeeq/D2ljq5X99TrF/ce+mcr7x2gV6W5gJEMcos=";
      };

      version = "3.43.2";

      src = fetchzip {
        name = "sqlite-${version}-source";
        url = "https://www.sqlite.org/src/tarball/sqlite.tar.gz?r=version-${version}";
        hash = hashes.${version};
      };

      mkBundle = name: mkSqliteExt {
        inherit name version src;
        sourceFiles = [ "ext/misc/${name}.c" ];
      };

      bundle = name:
        { inherit name; value = callPackage (mkBundle name) { }; };
    in
    names: lib.listToAttrs (builtins.map bundle names)
  ;

  sqlean =
    let
      version = "0.21.8";

      src = fetchFromGitHub {
        owner = "nalgeon";
        repo = "sqlean";
        rev = "a08c9c63d257c1ecd4b08d157c715fd6ec2117bd";
        hash = "sha256-NNA0Ha67Jvy8vNi5n1xSU8UscNoiISyQXyQPdOzQWrA=";
      };

      mkSqlean = name: mkSqliteExt {
        inherit name version src;
        sourceFiles = [ "src/sqlite3-${name}.c" ];
      };

      bundle = name:
        { inherit name; value = callPackage (mkSqlean name) { }; };
    in
    names: lib.listToAttrs (builtins.map bundle names)
  ;

in
bundled [
  "amatch"
  "btreeinfo"
  "closure"
  "completion"
  "decimal"
  "eval"
  "explain"
  "fileio"
  "fuzzer"
  "ieee754"
  "nextchar"
  "percentile"
  "prefixes"
  "regexp"
  "rot13"
  "series"
  "sha1"
  "shathree"
  "spellfix"
  "stmt"
  "totype"
  "uint"
  "unionvtab"
  "uuid"
  "wholenumber"
  "zorder"
  # "compress"
  # "dbdump"
  # "scrub"
  # "sqlar"
  # "zipfile"
] //
sqlean [
  "define"
]
