{ lib, ... }:

# Directory of calling function, because nix paths are a pain
caller:
# Flake inputs
{ self, nixpkgs, ... }@inputs:
preOverlays:
files:
let

  merged = lib.foldFor files (directory:
    let
      file = import directory (inputs // { inherit lib; });
    in
    if file ? "overlays" then { inherit (file) overlays; }
    else
      lib.subFlake {
        inherit caller directory;
        pnames = file.pnames or file;
        depends = file.depends or [ ];
      }
  );

  extension = {
    inherit lib;

    overlays.default = lib.pipe self.__depends [
      lib.attrsToList
      (lib.toposort (a: b: builtins.elem a.name b.value or [ ]))
      (x: x.result)
      (builtins.map (x: x.name))
      (ds: ds ++ lib.subtractLists (ds ++ [ "default" ]) (builtins.attrNames self.overlays))
      (builtins.map (d: self.overlays.${d}))
      (o: preOverlays ++ o)
      lib.composeManyExtensions
    ];
  } // lib.foldFor lib.platforms.all (system:
    let
      pkgs = nixpkgs.legacyPackages.${system}.extend self.overlays.default;
    in
    {
      packages.${system} =
        lib.flip lib.filterAttrs self.legacyPackages.${system} (_: a:
          lib.isDerivation a && builtins.elem system a.meta.platforms or { }
        );
      legacyPackages.${system} = self.overlays.default
        self.legacyPackages.${system}
        pkgs;
    });

in
lib.recursiveUpdate merged extension
