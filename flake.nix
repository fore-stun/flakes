{
  description = "Miscellaneous custom packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    rust.url = "github:oxalica/rust-overlay";
    rust.inputs.nixpkgs.follows = "nixpkgs";

    crane.url = "github:ipetkov/crane";

    gomod2nix.url = "github:nix-community/gomod2nix";
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

      ./media/video

      ./network/openapi
      ./network/storage
      ./network/tunnel

      ./utils/bluetooth
      ./utils/email
      ./utils/exif
      ./utils/generators
      ./utils/shell
      ./utils/writers
      ./utils/wayland

      ./scripts/darwin
      ./scripts/jujutsu
      ./scripts/nix
      ./scripts/pandoc
      ./scripts/pdf
      ./scripts/sync
      ./scripts/system
      ./scripts/text

      ./servers/caddy
      ./servers/oracle-cloud-agent
    ];
}
