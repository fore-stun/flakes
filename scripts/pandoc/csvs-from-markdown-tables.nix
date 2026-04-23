{ lib
, json-from-markdown-tables
, writers
}:
let
  pname = "csvs-from-markdown-tables";
  version = "0.1.0";

  script = writers.writeZshBin "${pname}" ''
    ${lib.getExe json-from-markdown-tables} --csv "$@"
  '';
in
lib.standalone {
  inherit version script;
  passthru = { inherit (json-from-markdown-tables.passthru) json_writer; };
}
