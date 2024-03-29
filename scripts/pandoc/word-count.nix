{ lib
, pandoc
, lua
, writers
}:
let
  pname = "word-count";
  version = "0.1.0";

  wordCount = writers.writeLuaBin lua "${pname}-filter.lua"
    {
      doCheck = "lua54+pandoc";
    } ''
    local function debug(enabled, f)
      if tonumber(enabled) > 0 then
        f()
      end
    end

    local function ignore(_)
      return {}
    end

    local total = 0

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

    return {
      {
        Pandoc = function(doc)
          local function walk(el, filename)
            local start = os.clock()
            words = 0
            el.blocks:walk(wordcount)
            print(words, filename)
            total = total + words
            debug(doc.meta.debug, function()
              io.stderr:write(string.format("%.2f ms\n", 1000 * (os.clock() - start)))
            end)
          end

          return doc:walk({
            Para = function(el)
              local onlyFiles = function(e)
                return e.tag == "Str"
              end
              for _, file in pairs(el.content:filter(onlyFiles)) do
                local rdoc = read(file.text)
                if rdoc ~= nil then
                  walk(rdoc, file.text)
                end
              end
              print(total, "total")
              os.exit(0)
            end,
          })
        end,
      },
    }
  '';

  script = writers.writeZshBin "${pname}" ''
    zparseopts -D -E -F -- \
      -from:=ARG_from f:=ARG_from \
      -debug=OPT_debug d=OPT_debug

    local -a infiles=("$@")

    if ! (( #infiles )); then
      [[ -t 0 ]] && return 3
      infiles=(-)
    fi

    wordCount() {
      local FROM="''${ARG_from[2]:-markdown}"

      local -a PANDOC_ARGS=(
        -r''${FROM} -wnative
        -M debug="$(( $#OPT_debug ))"
        --lua-filter=${lib.getExe wordCount}
      )

      ${pandoc}/bin/pandoc "''${(@)PANDOC_ARGS}" "$@"
    }

    wordCount "''${(@)infiles}"
  '';
in
lib.standalone {
  inherit version script;
  passthru = { inherit wordCount; };
}
