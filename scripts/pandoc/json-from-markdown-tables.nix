{ lib
, jo
, pandoc
, writeTextDir
, writers
}:
let
  pname = "json-from-markdown-tables";
  version = "0.1.0";

  json_writer = writeTextDir "${pname}-writer.lua" ''
    function debug(enabled, f)
      if tonumber(enabled) > 0 then
        f()
      end
    end

    local json = require("pandoc.json")

    function Writer(doc)
      rename = {}
      if doc.meta.rename then
        rename = json.decode(pandoc.utils.stringify(doc.meta.rename)) or {}
      end

      local results = {}

      doc:walk({
        Table = function(tbl)
          debug(doc.meta.debug or "0", function()
            io.stderr:write(string.format("Found table\n%s\n", tbl.head))
          end)

          local headers = {}
          for _, cell in ipairs(tbl.head.rows[1].cells) do
            local h = pandoc.utils.stringify(cell.contents)
            table.insert(headers, rename[h] or h)
          end

          for _, row in ipairs(tbl.bodies[1].body) do
            local obj = {}
            for i, cell in ipairs(row.cells) do
              obj[headers[i]] = pandoc.utils.stringify(cell.contents)
            end
            table.insert(results, obj)
          end
        end,
      })

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
        --wrap=none
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
  passthru = { inherit json_writer; };
}
