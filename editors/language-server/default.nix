{ self, lib, nixpkgs, ... }:

let
  pnames = [ "csharp-ls" "fsharp-language-server" "tailwindcss-language-server" ];
in
{
  overlays.language-server = final: prev: lib.foldFor pnames (pname: {
    ${pname} = prev.callPackage (./. + "/${pname}.nix") { };
  });
} //
lib.foldFor lib.platforms.all (system: {
  packages.${system} = self.overlays.language-server
    self.packages.${system}
    nixpkgs.legacyPackages.${system};
})
