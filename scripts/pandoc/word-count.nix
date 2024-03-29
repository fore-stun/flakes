{ lib
, gawk
, lua
, moreutils
, pandoc
, perl
, writers
}:
let
  pname = "word-count";
  version = "0.1.0";

  wordCount = writers.writeLuaBin lua "${pname}-filter.lua"
    {
      doCheck = "lua54+pandocWriter";
    } ''
    local function debug(enabled, f)
      if tonumber(enabled) > 0 then
        f()
      end
    end

    local function ignore(_)
      return {}
    end

    local words = 0

    local wordcount = {
      Str = function(el)
        -- we don't count a word if it's entirely punctuation:
        if el.text:match("%P") then
          words = words + 1
        end
      end,

      Code = function(el)
        local _, n
        _, n = el.text:gsub("%S+", "")
        words = words + n
      end,

      CodeBlock = ignore,
      BlockQuote = ignore,
    }

    local function read(filename)
      local handle = io.open(filename, "r")
      local doc
      if handle ~= nil then
        doc = pandoc.read(handle:read("*a"))
        handle:close()
      end
      return doc
    end

    Writer = pandoc.scaffolding.Writer

    Writer.Pandoc = function(doc)
      local function direct(el, filename)
        local start = os.clock()
        words = 0
        el.blocks:walk(wordcount)
        print(words, filename)
        debug(doc.meta.debug, function()
          io.stderr:write(string.format("%.2f ms\n", 1000 * (os.clock() - start)))
        end)
      end

      if tonumber(doc.meta.direct) > 0 then
        direct(doc, "stdin")
      else
        doc:walk({
          Para = function(el)
            local onlyFiles = function(e)
              return e.tag == "Str"
            end
            for _, file in pairs(el.content:filter(onlyFiles)) do
              local rdoc = read(file.text)
              if rdoc ~= nil then
                direct(rdoc, file.text)
              end
            end
          end,
        })
      end

      return {}
    end
  '';

  script = writers.writeZshBin "${pname}" ''
    zparseopts -D -E -F -- \
      -format-from:=ARG_format_from f:=ARG_format_from \
      -files-from:=ARG_files_from F:=ARG_files_from \
      -debug=OPT_debug d=OPT_debug

    local -a infiles=("$@")

    local DIRECT=0
    if (( $#ARG_files_from )); then
      local FILES_FROM
      if [[ "''${ARG_files_from[2]}" = "-" ]]; then
        read -r -d"" FILES_FROM || {}
      else
        read -r -d"" FILES_FROM < "''${ARG_files_from[2]}" || {}
      fi
      infiles+=("''${(f)FILES_FROM}")
    fi

    if ! (( $#infiles )); then
      [[ -t 0 ]] && return 3
      infiles=(-)
      DIRECT=1
    fi

    print -l -- "''${(@)infiles}" >&2

    wordCount() {
      local FROM="''${ARG_format_from[2]:-markdown}"

      local -a pandoc_args=(
        -r''${FROM} -w${lib.getExe wordCount}
        -M debug="$(( $#OPT_debug ))"
        -M direct="''${DIRECT}"
      )

      ${lib.getExe pandoc} "''${(@)pandoc_args}" =(print -l -- "$@")
      #   | ${lib.getExe perl} -pe 'chomp if eof' \
      #   | ${moreutils}/bin/ifne ${lib.getExe gawk} -v OFS="\t" \
      #     '{a+=$1; print $0} END {print a, "total"}'
    }

    wordCount "''${(@)infiles}"
  '';
in
lib.standalone {
  inherit version script;
  passthru = { inherit wordCount; };
}
