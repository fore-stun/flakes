{ lib
, writers
}:
let
  pname = "nix-toplevel";
  version = "0.1.0";

  script = writers.writeZshBin "${pname}" ''
    zparseopts -D -E -F -- \
      F:=ARG_flake -flake:=ARG_flake

    local HOSTNAME="$(hostname -s)"
    local PLATFORM="''$([[ "''$(uname)" = "Darwin" ]] && print "darwin" || print "nixos")"

    local FLAKE="''${ARG_flake[2]:-.}"

    function nixos() {
      local -a build_args=(
        nix build
        --print-build-logs
        --keep-going
        --no-eval-cache
        "''${FLAKE}#nixosConfigurations.''${(qqq)HOSTNAME}.config.system.build.toplevel"
      )

      systemd-inhibit -- "''${(@)build_args}"
    }

    function darwin() {
      local -a build_args=(
        nix build
        --print-build-logs
        --keep-going
        --no-eval-cache
        "''${FLAKE}#darwinConfigurations.''${(qqq)HOSTNAME}.system"
      )

      caffeinate -i -- "''${(@)build_args}"
    }

    if [[ $PLATFORM = "darwin" ]]; then
      darwin
    elif [[ $PLATFORM = "nixos" ]]; then
      nixos
    fi
  '';
in
lib.standalone {
  inherit version script;
}
