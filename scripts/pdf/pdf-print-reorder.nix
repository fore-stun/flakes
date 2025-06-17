{ lib
, exiftool
, qpdf
, writers
}:
let
  pname = "pdf-print-reorder";
  version = "0.1.0";

  script = writers.writeZshBin "${pname}" ''
    pdfPrintReorder() {
      local INPUT_BASE="''${''${1?Input PDF}:r}"

      local PAGES
      ${lib.getExe exiftool} -b -PageCount "''${INPUT_BASE}.pdf" | { read -r PAGES || : }
      if ! (( PAGES )); then
        print -l -- "Could not ascertain page count" >&2
        return 3
      fi
      print -l -- "Pages: ''${PAGES?}" >&2

      local -a ARGS_qpdf=(
        "''${INPUT_BASE}.pdf" --pages
        . 1-z:odd
      )
      if (( PAGES % 2 )); then
        ARGS_qpdf+=(. z-1:even)
      else
        ARGS_qpdf+=(. z-1:odd)
      fi
      ARGS_qpdf+=(
        -- "''${INPUT_BASE}_print.pdf"
      )
      print -- "''${(@)ARGS_qpdf}" >&2

      read -qs "REPLY?Run qpdf? (y/N)" >&2
      if [[ "$REPLY" != "y" ]]; then
        return 2
      fi

      ${lib.getExe qpdf} "''${(@)ARGS_qpdf}"
    }

    pdfPrintReorder "$@"
  '';
in
lib.standalone {
  inherit version script;
}
