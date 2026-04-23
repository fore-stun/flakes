{ lib
, jo
, pandoc
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

  json_writer = writeTextDir "${pname}-writer.lua" ''
    local json = require 'pandoc.json'

    function Writer(doc)
      local results = {}
      for _, block in ipairs(doc.blocks) do
        if block.t == 'Table' then
          local headers = {}
          for _, cell in ipairs(block.head.rows[1].cells) do
            table.insert(headers, pandoc.utils.stringify(cell.contents))
          end
          for _, row in ipairs(block.bodies[1].body) do
            local obj = {}
            for i, cell in ipairs(row.cells) do
              obj[headers[i]] = pandoc.utils.stringify(cell.contents)
            end
            table.insert(results, obj)
          end
        end
      end
      return json.encode(results)
    end
  '';

  script = writers.writeZshBin "${pname}" ''
    zparseopts -D -E -F -- \
      -pandoc-extra-arg+:=pandoc_extra P+:=pandoc_extra \
      -csv=OPT_csv_output C=OPT_csv_output \
      -headers+:=ARG_headers h+:=ARG_headers \
      -debug=OPT_debug d=OPT_debug

    local -a infiles=("$@")

    if ! (( #infiles )); then
      [[ -t 0 ]] && return 3
      infiles=(-)
    fi

    local RENAME_JSON="{}"

    local -a rename_headers
    if (( $#ARG_headers )); then
      for _ h in "''${(@)ARG_headers}"; do
        rename_headers+=("$h")
      done
    fi
    ${lib.getExe jo} -e "''${(@)rename_headers}" \
      | { read -r -d "" RENAME_JSON || : }

    if (( $#OPT_debug )); then
      print -l -- "Renaming:" "''${RENAME_JSON}" >&2
    fi

    extractJson() {
      local -a PANDOC_ARGS=(
        -rmarkdown -w"${json_writer}/${pname}-writer.lua"
        -M debug="$(( #OPT_debug ))"
        -M rename:"''${RENAME_JSON}"
        --wrap=none --lua-filter=${lua}
      )

      local PANDOC_EXTRA_SIGIL=(--pandoc-extra-arg -P)
      PANDOC_ARGS+=("''${(@)pandoc_extra:|PANDOC_EXTRA_SIGIL}")

      ${lib.getExe pandoc} "''${(@)PANDOC_ARGS}" "$@"
    }

    extractJson "''${(@)infiles}"
  '';
in
lib.standalone {
  inherit version script;
  passthru = { inherit json_writer lua; };
}
