{ nixpkgs }:

let
  lib = nixpkgs.lib.recursiveUpdate nixpkgs.lib {
    inherit foldMap foldFor mkApp;
    platforms = { inherit mySystems; };
  };

  foldMap = f:
    builtins.foldl' (acc: x: lib.recursiveUpdate acc (f x)) { };

  foldFor = lib.flip foldMap;

  mySystems = [
    "x86_64-linux"
    "aarch64-linux"
    "x86_64-darwin"
    "aarch64-darwin"
  ];

  mkApp = program: { type = "app"; inherit program; };
in
lib
