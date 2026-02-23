{ self, lib, nixpkgs, ... }:

let
  subflake = "llm";
  pnames = [ "llmfit" ];
in
{
  overlays."${subflake}" = final: prev:
    let
      extras = { };
    in
    lib.foldFor pnames (pname: {
      ${pname} = prev.callPackage
        (./. + "/${pname}.nix")
        (extras."${pname}" or { });
    });
} //
lib.foldFor lib.platforms.all (system:
  let
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    packages.${system} =
      lib.filterAttrs (_: lib.isDerivation) self.legacyPackages.${system};
    legacyPackages.${system} = self.overlays."${subflake}"
      self.legacyPackages.${system}
      pkgs;
  })
