{
  description = "Miscellaneous custom packages";

  outputs = { nixpkgs, ... }@inputs:
    let
      lib = import ./flake-lib.nix { inherit nixpkgs; };

      mergeFlakeOutputs =
        lib.foldMap (file: import file (inputs // { inherit lib; }));
    in
    mergeFlakeOutputs [
      ./servers/oracle-cloud-agent
    ] // { inherit lib; };
}
