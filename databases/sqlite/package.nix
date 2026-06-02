{ lib
, makeWrapper
, sqlite
, sqlitePlugins
, stdenvNoCC
, symlinkJoin
, testers

, version ? sqlite.version
}:
let
  pathType = if stdenvNoCC.isDarwin then "DYLD" else "LD";

  plugins = lib.filterAttrs (_: a: lib.isDerivation a)
    (sqlitePlugins.override { inherit version; });

  drv = symlinkJoin
    {
      inherit (sqlite) name version;
      buildInputs = [ makeWrapper ];

      passthru = {
        inherit sqlite;
        # It can be useful for consumers to know which plugins are available.
        libPaths = lib.mapAttrs (_: d: d.libPath) plugins;
        tests.pkg-config = testers.hasPkgConfigModules {
          package = drv;
        };
      };

      meta = {
        mainProgram = "sqlite3";
        pkgConfigModules = [ "sqlite3" ];
      };

      postBuild = ''
        wrapProgram "$out/bin/sqlite3" \
          --prefix ${pathType}_LIBRARY_PATH : "$out/lib/sqlite/ext"
      '';
      paths = [ sqlite sqlite.dev ] ++ builtins.attrValues plugins;
    };

in
drv
