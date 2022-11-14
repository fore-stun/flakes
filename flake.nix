{
  description = "Miscellaneous custom packages";

  outputs = { nixpkgs, ... }@inputs:
    let
      lib = import ./lib {
        lib = import ./flake-lib.nix { inherit nixpkgs; };
      };

      mergeFlakeOutputs =
        lib.foldMap (file: import file (inputs // { inherit lib; }));
    in
    mergeFlakeOutputs [
      ./databases/sqlite

      ./utils/writers

      ./scripts/pandoc
      ./scripts/text

      ./servers/oracle-cloud-agent
    ] // { inherit lib; };
}
