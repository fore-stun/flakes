{
  description = "Miscellaneous custom packages";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";

    rust.url = "github:oxalica/rust-overlay";
    rust.inputs.nixpkgs.follows = "nixpkgs";
    rust.inputs.flake-utils.follows = "flake-utils";

    crane.url = "github:ipetkov/crane";
    crane.inputs.nixpkgs.follows = "nixpkgs";

    gomod2nix.url = "github:fore-stun/gomod2nix/fix-recursive-symlinker";
    gomod2nix.inputs.nixpkgs.follows = "nixpkgs";
    gomod2nix.inputs.flake-utils.follows = "flake-utils";
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      lib = import ./lib {
        lib = import ./flake-lib.nix { inherit nixpkgs; };
      };

      mergeFlakeOutputs =
        lib.foldMap (file: import file (inputs // { inherit lib; }));

      flakeOverlays = [ ];

      buildFlakeFrom = files: lib.recursiveUpdate
        (mergeFlakeOutputs files)
        {
          inherit lib;

          overlays.default = lib.pipe self.overlays [
            (lib.filterAttrs (n: _: n != "default"))
            builtins.attrValues
            (o: o ++ flakeOverlays)
            lib.composeManyExtensions
          ];
        };

    in
    buildFlakeFrom [
      ./dependencies/python
      ./dependencies/lua

      ./deploy/aztfexport
      ./deploy/org-formation

      ./databases/postgres
      ./databases/sqlite

      ./editors/language-server
      ./editors/formatter

      ./utils/email
      ./utils/exif
      ./utils/generators
      ./utils/shell
      ./utils/writers

      ./scripts/nix
      ./scripts/pandoc
      ./scripts/sync
      ./scripts/text

      ./servers/caddy
      ./servers/oracle-cloud-agent
    ];
}
