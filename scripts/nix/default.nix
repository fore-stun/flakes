{ self, lib, nixpkgs, ... }:

let
  pnames = [
    "nix-load-systemd-unit"
    "home-manager-specialisation"
  ];
in
{
  overlays.nix-script = final: prev: lib.foldFor pnames (pname: {
    ${pname} = prev.callPackage (./. + "/${pname}.nix") {
      inherit (final) writers;
      inherit lib;
    };
  });
} //
lib.foldFor lib.platforms.all (system:
  {
    packages.${system} = self.overlays.nix-script
      self.legacyPackages.${system}
      nixpkgs.legacyPackages.${system};
  } //
  lib.foldFor pnames (pname: {
    apps.${system}.${pname} = {
      type = "app";
      program = self.packages.${system}.${pname} + "/bin/${pname}";
    };
  })
)
