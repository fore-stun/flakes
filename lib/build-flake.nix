{ lib, ... }:

# Directory of calling function, because nix paths are a pain
caller:
# Flake inputs
{ self, ... }@inputs:
preOverlays:
files:

let

  merged = lib.foldFor files (file:
    import file (inputs // { inherit lib; })
  );

  extension = {
    inherit lib;

    overlays.default = lib.pipe self.overlays [
      (lib.filterAttrs (n: _: n != "default"))
      builtins.attrValues
      (o: preOverlays ++ o)
      lib.composeManyExtensions
    ];
  };

in
lib.recursiveUpdate merged extension
