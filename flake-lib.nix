{ nixpkgs }:

let
  lib = nixpkgs.lib // { inherit foldMap foldFor mkApp; };

  foldMap = f:
    builtins.foldl' (acc: x: lib.recursiveUpdate acc (f x)) { };

  foldFor = lib.flip foldMap;

  mkApp = program: { type = "app"; inherit program; };
in
lib
