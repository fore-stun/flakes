{ self, lib, nixpkgs, ... }:

let
  pname = "oracle-cloud-agent";
  systems = [ "x86_64-linux" "aarch64-linux" ];
in
lib.foldFor systems (system: {
  packages.${system}.${pname} =
    nixpkgs.legacyPackages.${system}.callPackage ./package.nix { };
  apps.${system}.gomon = {
    type = "app";
    program = self.packages.${system}.${pname}.plugin + "/bin/gomon";
  };
  nixosModules.gomon = import ./gomon.nix { pkgs = self.packages.${system}; };
})
