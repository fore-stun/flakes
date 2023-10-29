{
  description = "Miscellaneous custom packages";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";

    rust.url = "github:oxalica/rust-overlay";
    rust.inputs.nixpkgs.follows = "nixpkgs";
    rust.inputs.flake-utils.follows = "flake-utils";

    mtags.url = "github:dbaynard/mtags";
    mtags.inputs.nixpkgs.follows = "nixpkgs";

    postgrest.url = "github:fore-stun/postgrest/flake";

    spanx.url = "github:fore-stun/spanx";
    spanx.inputs.nixpkgs.follows = "nixpkgs";
    spanx.inputs.flake-utils.follows = "flake-utils";
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      lib = import ./lib {
        lib = import ./flake-lib.nix { inherit nixpkgs; };
      };

      mergeFlakeOutputs =
        lib.foldMap (file: import file (inputs // { inherit lib; }));

      flakeOverlays = [
        inputs.mtags.overlays.default
        inputs.spanx.overlays.default
      ];

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

      ./deploy/aztfexport
      ./deploy/org-formation

      ./databases/postgres
      ./databases/sqlite

      ./editors/language-server
      ./editors/formatter

      ./utils/email
      ./utils/exif
      ./utils/generators
      ./utils/writers

      ./scripts/nix
      ./scripts/pandoc
      ./scripts/sync
      ./scripts/text

      ./servers/caddy
      ./servers/oracle-cloud-agent
    ];
}
