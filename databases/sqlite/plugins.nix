{ lib
, callPackage
, fetchFromGitHub
, fetchzip
, sqlite
, xlite
, version ? sqlite.version
}:

let
  mkSqliteExt =
    { name
    , version
    , src
    , sourceFiles # relative to $src
    , includeDirs ? [ ] # relative to $src
    , includeFiles ? [ ] # relative to $src
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

      SOURCES_SEP = lib.concatStringsSep "" sourceFiles;
      inherit EXT_DIR;
      INCLUDE_DIRS_SEP = lib.concatMapStringsSep "" (d: "-I${d}") includeDirs;
      INCLUDE_FILES_SEP = lib.concatMapStringsSep "" (f: "-include${f}") includeFiles;

      passthru = {
        # Consumers need to know the actual output file
        libPath = "${EXT_DIR}${outFile}";
      };

      buildPhase = ''
        shopt -s nullglob
        IFS='' read -ra SOURCES <<< "''${SOURCES_SEP?}"
        IFS='' read -ra INCLUDE_DIRS <<< "''${INCLUDE_DIRS_SEP?}"
        IFS='' read -ra INCLUDE_FILES <<< "''${INCLUDE_FILES_SEP?}"
        "$CC" -v -g -fPIC ${if stdenv.isDarwin then "-dynamiclib" else "-shared"} \
          -I"${sqlite.dev}/include" \
          ''${INCLUDE_DIRS[@]} \
          ''${INCLUDE_FILES[@]} \
          ''${SOURCES[@]} \
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
        "3.50.2" = "sha256-lL7025+mVujqgckSHHtOzL+y1KaytmvjXGlCaEb6XVM=";
        "3.50.4" = "sha256-YXzEu1/BC41mv08wm67kziRkQsSEmd/N00pY7IwF3rc=";
        "3.51.1" = "sha256-lU5ytYZsJeqgbqlh+Kf/IK/FPur4W1MAA92RRbku2jY=";
        "3.51.2" = "sha256-4fpNZ08bcy8y9RjT7WUHIF8ok93L1DYYjYv2sBcb9q0=";
      };

      src = fetchFromGitHub {
        name = "sqlite-${version}-source";
        owner = "sqlite";
        repo = "sqlite";
        tag = "version-${version}";
        hash = hashes.${version} or lib.fakeHash;
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
      version = "0.27.1";

      src = fetchFromGitHub {
        owner = "nalgeon";
        repo = "sqlean";
        rev = "94d8934683ee079a3e8639a7d8445f8b1ea52e36";
        hash = "sha256-So4yUr9U1WCP1d6wJiJU1XkaCxmEaLMos6tlxQHmcxE=";
      };

      mkSqlean = args@{ name, ... }: mkSqliteExt {
        inherit name version src;
        sourceFiles = [
          "src/sqlite3-${name}.c"
          "src/${name}/*.c"
        ] ++ args.sourceFiles or [ ];
        includeDirs = [ "src" ] ++ args.includeDirs or [ ];
        includeFiles = args.includeFiles or [ ];
      };

      bundle = x:
        let
          r = if builtins.typeOf x == "string" then { name = x; } else x;
        in
        { inherit (r) name; value = callPackage (mkSqlean r) { }; };
    in
    names: lib.listToAttrs (builtins.map bundle names)
  ;

  sqlean-incubator =
    let
      version = "unstable-2024-01-26";

      src = fetchFromGitHub {
        owner = "nalgeon";
        repo = "sqlean";
        rev = "fe952df6ea42b2e4ac65d2287d3b86ab75f5a2e0";
        hash = "sha256-LZrX/JgBnVnxes0+k4T6RFTmxYhHuxe6y0SjxdPrXTc=";
      };

      mkSqleanI = name: mkSqliteExt {
        inherit name version src;
        sourceFiles = [ "src/${name}.c" ];
      };

      bundle = name:
        { inherit name; value = callPackage (mkSqleanI name) { }; };
    in
    names: lib.listToAttrs (builtins.map bundle names)
  ;

  pivot_vtab =
    let
      name = "pivot_vtab";
      version = "unstable-2023-11-14";

      src = fetchFromGitHub {
        owner = "dmagyari";
        repo = "pivot_vtab";
        rev = "1e0379e1e4a33528a1d3cc3886fb0f230acfac2f";
        hash = "sha256-3e/9B1WQJU/XkbhCeoNu8az0hj3DlasBUIsFygo5Iew=";
      };

      mkExt = mkSqliteExt {
        inherit name version src;
        sourceFiles = [ "${name}.c" ];
      };
    in
    callPackage mkExt { }
  ;

in
{
  inherit
    pivot_vtab
    xlite
    ;
} //
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
  "prefixes"
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
  "ipaddr"
  "math"
  {
    name = "regexp";
    includeFiles = [ "src/regexp/constants.h" ];
    sourceFiles = [ "src/regexp/pcre2/*.c " ];
  }
  "stats"
  {
    name = "text";
    sourceFiles = [ "src/text/utf8/*.c " ];
  }
  "unicode"
  "vsv"
] //
sqlean-incubator [
  # "array"
  "bloom"
  # "cron"
  # "path"
  # "pivotvtab"
  "stats2"
  "stats3"
]
