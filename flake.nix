{
  description = "Miscellaneous custom packages";

  inputs = {
    mtags.url = "github:dbaynard/mtags";
    mtags.inputs.nixpkgs.follows = "nixpkgs";
  };

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
      ./dependencies/python

      ./databases/sqlite

      ./editors/language-server

      ./utils/writers

      ./scripts/pandoc
      ./scripts/sync
      ./scripts/text

      ./servers/oracle-cloud-agent
    ];
}
