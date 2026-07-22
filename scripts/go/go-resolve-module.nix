{ lib
, gh
, gnused
, jq
, writers
}:
let
  pname = "go-resolve-module";
  version = "0.1.0";

  script = writers.writeZshBin "${pname}" ''
    resolvePlugin() {
      zparseopts -D -E -F -- \
        n=OPT_dry_run -dry-run=OPT_dry_run

      local INPUT="''${1?Input URL}"
      local REPO
      local TAG
      ${lib.getExe gnused} -r \
          -e 's#@#/#g' \
          -e 's#^(https://)?github.com/([^/]+/[^/]+)[/](.+)#\2 \3#' \
          <<< "$INPUT" \
        | read -r REPO TAG
      local MODULE="''${(L)INPUT%@*}"
      print -l -- "Input:" "  MODULE: ''${MODULE}" "  REPO: ''${REPO}" "  TAG: ''${TAG}" >&2

      if (( $#OPT_dry_run )); then
        return 0
      fi

      print -l -- "Resolving version with github API" >&2

      local GO_VERSION
      ${lib.getExe gh} api "repos/''${REPO?}/commits/''${TAG?}" \
        | ${lib.getExe jq} -r '"v0.0.0-" + (.commit.committer.date | gsub("[-T:Z]"; "")) + "-" + .sha[0:12]' \
        | { read -r -d "" GO_VERSION || : }

      local PLUGIN_URL="''${MODULE?}@''${GO_VERSION?}"
      print -- "''${(qqq)PLUGIN_URL}"
    }

    resolvePlugins() {
      zparseopts -D -E -F -- \
        v=OPT_verbose -verbose=OPT_verbose \
        n=OPT_dry_run -dry-run=OPT_dry_run

      local -a inargs=("''${(@)@}")
      if ! (( $#@ )); then
        if [[ -t 0 ]]; then
          print -- "No arguments supplied" >&2
          return 3
        fi
        local INARGS
        read -r -d "" INARGS || :
        inargs=("''${(f)INARGS}")
        unset INARGS
      fi

      if (( $#inargs )); then
        for arg in "''${(@)inargs}"; do
          local -a args=()
          if (( $#OPT_dry_run )); then
            args+=("-n")
          fi
          args+=("$arg")
          if (( $#OPT_verbose )); then
            resolvePlugin "''${(@)args}" || :
          else
            resolvePlugin "''${(@)args}" 2>/dev/null || :
          fi
        done
      fi
    }

    resolvePlugins "$@"
  '';

in
lib.standalone {
  inherit version script;
}
