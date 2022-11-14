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
      version = "3.39.3";

      src = fetchzip {
        name = "sqlite-${version}-source";
        url = "https://www.sqlite.org/src/tarball/sqlite.tar.gz?r=version-${version}";
        hash = "sha256-DkF8tP5Tbg40ZLsFqY7xYndhyFeF4H8N3WMb/HVaptk=";
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
      version = "0.17.1";

      src = fetchFromGitHub {
        owner = "nalgeon";
        repo = "sqlean";
        rev = "74116426cf9645d055238d136a837a7474ccab31";
        hash = "sha256-lUsDu+air7dnC1yO6STcFJt77VR3Z0S9N0QoVWSgONI=";
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
bundled
  [
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
