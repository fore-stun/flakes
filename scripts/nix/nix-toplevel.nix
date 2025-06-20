{ lib
, writers
}:
let
  pname = "nix-toplevel";
  version = "0.1.0";

  script = writers.writeZshBin "${pname}" ''
    zparseopts -D -E -F -- \
      d=OPT_dry_run -dry-run=OPT_dry_run \
      l=OPT_no_link -no-link=OPT_no_link \
      O=OPT_offline -offline=OPT_offline \
      f+:=ARG_flags -nix-flags+:=ARG_flags \
      F:=ARG_flake -flake:=ARG_flake

    typeset HOSTNAME="$(hostname -s)"
    typeset PLATFORM="''$([[ "''$(uname)" = "Darwin" ]] && print "darwin" || print "nixos")"

    typeset FLAKE="''${ARG_flake[2]:-.}"

    typeset -a build_args=(
      nix build
      --print-build-logs
      --keep-going
      --no-eval-cache
    )

    if (( $#OPT_offline )); then
      build_args+=(--offline)
    fi

    if (( $#OPT_no_link )); then
      build_args+=(--no-link --print-out-paths)
    fi

    if (( $#ARG_flags )); then
      for _ flag in "''${(@)ARG_flags}"; do
        build_args+=("''${flag}")
      done
    fi

    function nixos() {
      build_args+=(
        "''${FLAKE}#nixosConfigurations.''${(qqq)HOSTNAME}.config.system.build.toplevel"
      )

      if (( $#OPT_dry_run )); then
        print -l -- "''${(@)build_args}" >&2
        return 0
      fi

      systemd-inhibit -- "''${(@)build_args}"
    }

    function darwin() {
      build_args+=(
        "''${FLAKE}#darwinConfigurations.''${(qqq)HOSTNAME}.system"
      )

      if (( $#OPT_dry_run )); then
        print -l -- "''${(@)build_args}" >&2
        return 0
      fi

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
