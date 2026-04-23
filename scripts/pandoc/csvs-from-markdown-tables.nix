{ lib
, json-from-markdown-tables
, visidata
, writers
}:
let
  pname = "csvs-from-markdown-tables";
  version = "0.2.0";

  script = writers.writeZshBin "${pname}" ''
    csvFromJson() {
      local -a visidata_args=(
        ${lib.getExe visidata}
        -f json
        -b
        --save-filetype=csv
        --null-value=""
        -o -
      )

      local fifo=$(mktemp -u)
      mkfifo "$fifo"
      trap "rm -f '$fifo'" EXIT

      "''${(@)visidata_args}" 2>"$fifo" &
      local VD_PID=$!

      local STDERR
      { read -r -d "" STDERR || : } < "$fifo"

      wait "$VD_PID"
      if (( ? )); then
        print -r -l -- "$STDERR" >&2
      fi
    }

    ${lib.getExe json-from-markdown-tables} "$@" \
      | csvFromJson
  '';
in
lib.standalone {
  inherit version script;
  passthru = { inherit (json-from-markdown-tables.passthru) json_writer; };
}
