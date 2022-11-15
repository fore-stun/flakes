{ lib
, makeWrapper
, sqlite
, sqlitePlugins
, stdenvNoCC
, symlinkJoin
}:
let
  pathType = if stdenvNoCC.isDarwin then "DYLD" else "LD";

  plugins = lib.filterAttrs (_: a: lib.isDerivation a) sqlitePlugins;

in
symlinkJoin {
  name = "sqlite";
  buildInputs = [ makeWrapper ];

  passthru = {
    # It can be useful for consumers to know which plugins are available.
    libPaths = lib.mapAttrs (_: d: d.libPath) plugins;
  };

  postBuild = ''
    wrapProgram "$out/bin/sqlite3" \
      --prefix ${pathType}_LIBRARY_PATH : "$out/lib/sqlite/ext"
  '';
  paths = [ sqlite ] ++ builtins.attrValues plugins;
}
