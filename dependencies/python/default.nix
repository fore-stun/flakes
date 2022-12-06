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
  overlays.python = final: prev: {
    python3 = prev.python3 // {
      pkgs = prev.python3.pkgs.overrideScope (lib.composeManyExtensions [
        (_: _: newPackages final prev)
      ]);

      packageOverrides = lib.warn ''
        `python3.packageOverrides` does not compose;
        instead, manually replace the `pkgs` attr of `python3` with `python3.pkgs.overrideScope` applied to the overrides.
      ''
        prev.python3.packageOverrides;
    };

    python3Packages = final.python3.pkgs;
  };

} //
lib.foldFor lib.platforms.all (system: {
  packages.${system} = self.overlays.python
    self.packages.${system}
    nixpkgs.legacyPackages.${system};
})
