{ self, lib, nixpkgs, ... }:

let
  pnames = [
    "DataProperty"
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
  overlays.python = final: prev: lib.pythonScopeWith prev "3" [
    (_: _: newPackages final prev)
  ];

} //
lib.foldFor lib.platforms.all (system: {
  legacyPackages.${system} = self.overlays.python
    self.legacyPackages.${system}
    nixpkgs.legacyPackages.${system};
})
