{ lib
, writers
}:
let
  pname = "jj-scripts";
  version = "0.1.0";

  functions = { };

  wrapFunctions =
    let
      f = name: inner:
        let fname = "_jj_${lib.replaceStrings ["-"] ["_"] name}";
        in ''
          renamed[${name}]="${fname}"
          ${fname}() {
          ${inner}
          }
        '';
    in
    lib.flip lib.pipe [
      (lib.mapAttrsToList f)
      (lib.concatStringsSep "\n\n")
    ];

  script = writers.writeZshBin "${pname}" ''
    typeset -A renamed

    ${wrapFunctions functions}
    function help() {
      echo "${pname} functions:"
      echo "> ''${(@)subcommands}"
    }

    local -a subcommands
    subcommands=(''${(k)functions:#_*} ''${(k)renamed})

    if [ $# -ge 1 ] && grep -q "$1" <<< "''${(@)subcommands}"
    then
      "''${renamed[(e)$1]:-$1}" "$@[2,-1]"
      exit 0
    else
      echo "Not a ${pname} sub-command: $1" >&2
      exit 2
    fi
  '';

in
lib.standalone {
  inherit version script;
}
