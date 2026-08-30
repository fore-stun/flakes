{ self, lib, nixpkgs, ... }:

let
  pnames = [ "huggingface-model-downloader" ];
in
{
  overlays.fetchers = final: prev:
    let
      fetchFromHuggingFace = prev.callPackage ./fetchFromHuggingFace.nix {
        inherit (final) huggingface-model-downloader;
      };
      extras = { };
    in
    lib.foldFor pnames
      (pname: {
        ${pname} = prev.callPackage
          (./. + "/${pname}.nix")
          (extras."${pname}" or { });
      }) // {
      inherit fetchFromHuggingFace;
    };
} //
lib.foldFor lib.platforms.all (system:
  let
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    packages.${system} =
      lib.filterAttrs (_: lib.isDerivation) self.legacyPackages.${system};
    legacyPackages.${system} = self.overlays.fetchers
      (pkgs // self.packages.${system})
      pkgs;
  })
