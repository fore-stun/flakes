{ self, lib, nixpkgs, ... }:

let
  pname = "oracle-cloud-agent";
  systems = [ "x86_64-linux" "aarch64-linux" ];
in
{
  overlays.${pname} = final: prev: {
    ${pname} = prev.callPackage ./package.nix { };
  };
} //
lib.foldFor systems (system: {
  packages.${system} = self.overlays.${pname}
    self.packages.${system}
    nixpkgs.legacyPackages.${system};
  apps.${system}.gomon = {
    type = "app";
    program = self.packages.${system}.${pname}.plugin + "/bin/gomon";
  };
  nixosModules.gomon = import ./gomon.nix { pkgs = self.packages.${system}; };
})
