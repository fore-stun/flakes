{ self, lib, nixpkgs, ... }:

let
  pnames = [
    "DataProperty"
    "SimpleSQLite"
    "appconfigpy"
    "envinfopy"
    "excelrd"
    "mbstrdecoder"
    "msgfy"
    "pytablereader"
    "retryrequests"
    "sqliteschema"
    "tabledata"
    "tcolorpy"
    "typepy"
    "yamldown"
  ];

  newPackages = final: prev: lib.foldFor pnames (pname: {
    ${pname} = prev.callPackage (./. + "/${pname}.nix") {
      inherit (final) python3Packages;
    };
  });

in
{
  overlays.python = final: prev:
    let
      pythonPkgsScope = prev.python3.pkgs.overrideScope (prev.lib.composeManyExtensions [
        (_: _: newPackages final prev)
      ]);
    in
    {
      python3 = prev.python3 // {
        pkgs = pythonPkgsScope;
        withPackages = f: prev.python3.buildEnv.override { extraLibs = f pythonPkgsScope; };

        packageOverrides = lib.warn ''
          `python3.packageOverrides` does not compose;
          instead, manually replace the `pkgs` attr of `python3` with `python3.pkgs.overrideScope` applied to the overrides.
        ''
          prev.python3.packageOverrides;
      };

      python3Packages = pythonPkgsScope;
    };

} //
lib.foldFor lib.platforms.all (system: {
  legacyPackages.${system} = self.overlays.python
    self.legacyPackages.${system}
    nixpkgs.legacyPackages.${system};
})
