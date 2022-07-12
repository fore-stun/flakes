{
  description = "Miscellaneous custom packages";

  outputs = { nixpkgs, ... }@inputs:
    let
      lib = nixpkgs.lib // { inherit foldMap forSystems mergeFlakeOutputs; };

      foldMap = f:
        builtins.foldl' (acc: x: lib.recursiveUpdate acc (f x)) { };

      forSystems = lib.flip foldMap;

      mergeFlakeOutputs =
        foldMap (file: import file (inputs // { inherit lib; }));
    in
    mergeFlakeOutputs [
      ./servers/oracle-cloud-agent
    ] // { inherit lib; };
}
