{ lib, ... }:

# Directory of calling function, because nix paths are a pain
caller:
# Flake inputs
{ self, nixpkgs, ... }@inputs:
preOverlays:
files:
let

  merged = lib.foldFor files (directory:
    let file = import directory (inputs // { inherit lib; });
    in {
      overlays = file.overlays or (lib.subFlake {
        inherit caller directory;
        pnames = file;
      }).overlays;
    });


  extension = {
    inherit lib;

    overlays.default = lib.pipe self.overlays [
      (lib.filterAttrs (n: _: n != "default"))
      builtins.attrValues
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
