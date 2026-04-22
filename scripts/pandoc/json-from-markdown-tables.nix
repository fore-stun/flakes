{ lib
, jq
, pandoc
, pup
, writeText
, writeTextDir
, writers
}:
let
  pname = "json-from-markdown-tables";
  version = "0.1.0";

  lua = writeText "${pname}-filter" ''
    function debug(enabled, f)
      if tonumber(enabled) > 0 then
        f()
      end
    end

    function Pandoc(doc)
      return doc:walk {
        Table = function(tbl)
          debug(doc.meta.debug, function()
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

    def cell_text:
      if .tag == "code" then "`" + (.children // [] | map(.text // "") | join("")) + "`"
      elif .children? then .children[] | cell_text
      elif .text? then .text
      else ""
      end;

    def uniform_arrays_from_pup_table:
        .[]
      | .children
      | map(
          .children
        | .[]
        | .children
        | arrays
        | map(select(.tag == "td" or .tag == "th") | cell_text)
        );

    def objects_from_uniform_arrays:
        .[0] as $headers
      | .[1:] as $rows
      | reduce ($rows | .[]) as $row
        ([]; . + [
          reduce range(0; $headers | length) as $i
            ({}; . + {($headers[$i]): ($row[$i])})
        ]);

    def from_pup_table:
        uniform_arrays_from_pup_table
      | objects_from_uniform_arrays;
  '';

  script = writers.writeZshBin "${pname}" ''
    zparseopts -D -E -F -- \
      -pandoc-extra-arg+:=pandoc_extra P+:=pandoc_extra \
      -csv=OPT_csv_output C=OPT_csv_output \
      -debug=OPT_debug d=OPT_debug

    local -a infiles=("$@")

    if ! (( #infiles )); then
      [[ -t 0 ]] && return 3
      infiles=(-)
    fi

    extractPandoc() {
      local -a PANDOC_ARGS=(
        -rmarkdown -whtml
        -M debug="$(( #OPT_debug ))"
        --wrap=none --lua-filter=${lua}
      )

      local PANDOC_EXTRA_SIGIL=(--pandoc-extra-arg -P)
      PANDOC_ARGS+=("''${(@)pandoc_extra:|PANDOC_EXTRA_SIGIL}")

      ${lib.getExe pandoc} "''${(@)PANDOC_ARGS}" "$@"
    }

    pupFromHTML() {
      ${lib.getExe pup} --plain --charset utf8 'table json{}'
    }

    fromPup() {
      local -a jq_args=(
        ${lib.getExe jq} -L${jqModule}/modules
      )

      if (( $#OPT_csv_output )); then
        jq_args+=(
          -rc
          'include "base"; uniform_arrays_from_pup_table | csv_from_uniform_arrays'
        )
      else
        jq_args+=(
          'include "base"; from_pup_table'
        )
      fi
    }

    extractPandoc "''${(@)infiles}" \
      | pupFromHTML \
      | fromPup
  '';
in
lib.standalone {
  inherit version script;
  passthru = { inherit lua; };
}
