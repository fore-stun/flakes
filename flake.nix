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

          overlays.default = lib.pipe self.overlays [
            (lib.filterAttrs (n: _: n != "default"))
            builtins.attrValues
            lib.composeManyExtensions
          ];
        };

    in
    buildFlakeFrom [
      ./databases/sqlite

      ./utils/writers

      ./scripts/pandoc
      ./scripts/sync
      ./scripts/text

      ./servers/oracle-cloud-agent
    ];
}
