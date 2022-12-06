{ lib
, jq
, pandoc
, pup
, writeText
, writeTextDir
, writers
}:
let
  pname = "csvs-from-markdown-tables";
  version = "0.1.0";

  lua = writeText "${pname}-filter" ''
    function debug(f)
      if tonumber(PANDOC_WRITER_OPTIONS.variables["debug"]) > 0 then
        f()
      end
    end

    function Pandoc(doc)
      return doc:walk {
        Table = function(tbl)
          debug(function()
            io.stderr:write(string.format("Found table\\n%s\\n", tbl.head))
          end)
          return tbl
        end
      }
    end
  '';

  jqModule = writeTextDir "modules/base.jq" ''
    def csv_from_uniform_arrays:
      .[] | [.[]] | @csv;

    def uniform_arrays_from_pup_table:
        .[]
      | .children
      | map(
          .children
        | .[]
        | .children
        | arrays
        | map(select(.tag == "td" or .tag == "th") | .text)
        );
  '';

  script = writers.writeZshBin "${pname}" ''
    zparseopts -D -E -F -- \
      -pandoc-extra-arg+:=pandoc_extra P+:=pandoc_extra \
      -debug=OPT_debug d=OPT_debug

    local -a infiles=("$@")

    if ! (( #infiles )); then
      [[ -t 0 ]] && return 3
      infiles=(-)
    fi

    extractPandoc() {
      local -a PANDOC_ARGS=(
        -rmarkdown -whtml
        -V debug="$(( #OPT_debug ))"
        --wrap=none --lua-filter=${lua}
      )

      local PANDOC_EXTRA_SIGIL=(--pandoc-extra-arg -P)
      PANDOC_ARGS+=("''${(@)pandoc_extra:|PANDOC_EXTRA_SIGIL}")

      ${pandoc}/bin/pandoc "''${(@)PANDOC_ARGS}" "$@"
    }

    csvFromHTML() {
      ${pup}/bin/pup --plain --charset utf8 'table json{}' \
        | ${jq}/bin/jq -rc -L${jqModule}/modules \
          'include "base"; uniform_arrays_from_pup_table | csv_from_uniform_arrays'
    }

    extractPandoc "''${(@)infiles}" \
      | csvFromHTML
  '';
in
lib.standalone {
  inherit version script;
  passthru = { inherit lua; };
}
