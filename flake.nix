{
  description = "Miscellaneous custom packages";

  inputs = {
    deno2nix.url = "github:SnO2WMaN/deno2nix";
    deno2nix.inputs.nixpkgs.follows = "nixpkgs";

    rust.url = "github:oxalica/rust-overlay";
    rust.inputs.nixpkgs.follows = "nixpkgs";

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

      flakeOverlays = [
        inputs.mtags.overlays.default
        inputs.deno2nix.overlay
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

      ./utils/email
      ./utils/generators
      ./utils/writers

      ./scripts/pandoc
      ./scripts/sync
      ./scripts/text

      ./servers/caddy
      ./servers/deno_bindgen
      ./servers/oracle-cloud-agent
    ];
}
