{ lib
, findutils
, jq
, writers
}:
let
  pname = "nix-load-systemd-unit";
  version = "0.1.0";

  script = writers.writeZshBin "${pname}" ''
    zparseopts -D -E -F -- \
      d=OPT_debug -debug=OPT_debug

    local UNIT_NAME="''${1?Unit name}.service"
    local HM_UNIT_FILE="systemd/user/''${UNIT_NAME}"

    local HOSTNAME="''${HOST:-''$(hostname -s)}"
    # I don’t remember why the Darwin option is here…
    local PLATFORM="''$([[ "''$(uname)" = "Darwin" ]] && print "darwin" || print "nixos")"

    function nixos() {

      local -a nixattr=(
        "''${PLATFORM}Configurations"
        "''${HOSTNAME}"
        "config"
        "systemd"
        "user"
        "units"
        "''${(qqq)UNIT_NAME}"
        "unit"
      )

      if (( #OPT_debug )); then
        print -- "Nixos path: n#''${(j:.:)nixattr}" >&2
      fi

      local OUTPATH
      nix build "n#''${(j:.:)nixattr}" --no-link --print-out-paths 2>/dev/null \
        | tail -n1 \
        | { read -r -d "" outpath || : }

      if (( ? )); then
        if (( #OPT_debug )); then
          print -- "Couldn’t build nixos unit file" >&2
        fi

        return 3
      fi

      if (( #OPT_debug )); then
        print -- "Nixos outpath: ''${OUTPATH}" >&2
      fi

      print -- "''${OUTPATH}/''${UNIT_NAME}"
    }

    function home_manager() {
      local -a nixattr=(
        "''${PLATFORM}Configurations"
        "''${HOSTNAME}"
        "config"
        "home-manager"
        "users"
        "''${USER}"
        "xdg"
        "configFile"
        "''${(qqq)HM_UNIT_FILE}"
        "source"
      )

      if (( #OPT_debug )); then
        print -- "Home manager path: n#''${(j:.:)nixattr}" >&2
      fi

      local OUTPATH
      nix eval --raw "n#''${(j:.:)nixattr}" \
        | ${findutils}/bin/xargs nix show-derivation \
        | ${lib.getExe jq} -r 'to_entries | .[0].key' \
        | ${findutils}/bin/xargs nix build --no-link --print-out-paths 2>/dev/null \
        | tail -n1 \
        | { read -r -d "" OUTPATH || : }

      if (( ? )); then
        if (( #OPT_debug )); then
          print -- "Couldn’t build home-manager unit file" >&2
        fi

        return 4
      fi

      if (( #OPT_debug )); then
        print -- "Home manager outpath: ''${OUTPATH}" >&2
      fi

      print -- "''${OUTPATH}/''${UNIT_NAME}"
    }

    local UNIT_FILE
    { nixos || home_manager } \
      | read -r UNIT_FILE

    if (( #OPT_debug )); then
      print -- "Unit file: ''${UNIT_FILE}" >&2
    fi

    local RUNDIR="''${XDG_RUNTIME_DIR?}/systemd/user"
    local OUT_FILE="''${RUNDIR}/''${UNIT_NAME}"

    mkdir -p "''${RUNDIR}"

    if [ -L "''${OUT_FILE}" ]; then
      unlink "''${OUT_FILE}"
    fi
    ln -sv "''${UNIT_FILE}" "''${RUNDIR}" >&2

    print -- "''${OUT_FILE}"
  '';
in
lib.standalone {
  inherit version script;
}
