{
  description = "Miscellaneous custom packages";

  outputs = { self, nixpkgs, ... }@inputs:
    let
      lib = import ./lib {
        lib = import ./flake-lib.nix { inherit nixpkgs; };
      };

      mergeFlakeOutputs =
        lib.foldMap (file: import file (inputs // { inherit lib; }));

      buildFlakeFrom = files: lib.recursiveUpdate
        (mergeFlakeOutputs files)
        {
          inherit lib;

          overlays.default = builtins.attrValues
            (lib.filterAttrs (n: _: n != "default") self.overlays);
        };

    in
    buildFlakeFrom [
      ./databases/sqlite

      ./utils/writers

      ./scripts/pandoc
      ./scripts/text

      ./servers/oracle-cloud-agent
    ];
}
