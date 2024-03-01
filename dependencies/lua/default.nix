{ self, lib, nixpkgs, ... }:

let
  pnames = [
    "LuaNLP"
  ];

  newPackages = lua: final: prev: lib.foldFor pnames (pname: {
    ${pname} = prev.callPackage (./. + "/${pname}.nix") {
      lua = final.${lua};
    };
  });

in
{
  overlays.lua = final: prev: lib.foldFor [ "luajit" "lua5" "lua5_4" ] (lua:
    let
      luaPkgsScope = prev.${lua}.pkgs.overrideScope (prev.lib.composeManyExtensions [
        (_: _: newPackages lua final prev)
      ]);
    in
    {
      ${lua} = prev.${lua} // {
        pkgs = luaPkgsScope;

        packageOverrides = lib.warn ''
          `${lua}.packageOverrides` does not compose;
          instead, manually replace the `pkgs` attr of `${lua}` with `${lua}.pkgs.overrideScope` applied to the overrides.
        ''
          prev.${lua}.packageOverrides;
      };

      "${builtins.replaceStrings ["_"] [""] lua}Packages" = luaPkgsScope;
    });

} //
lib.foldFor lib.platforms.all (system: {
  legacyPackages.${system} = self.overlays.lua
    self.legacyPackages.${system}
    nixpkgs.legacyPackages.${system};
})

