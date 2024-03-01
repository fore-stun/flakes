{ lib
, pandoc
, lua
, writeText
, writeTextDir
, writers
}:
let
  pname = "simple-markdown";
  version = "0.1.0";

  libraries = builtins.attrValues {
    inherit (lua.pkgs)
      LuaNLP
      ;
  };

  initLua =
    let
      luaEnv = if libraries == [ ] then lua else (lua.withPackages (_: libraries));
    in
    writeTextDir "init.lua" ''
      package.path = package.path .. ";${luaEnv.luaPath}"
      package.cpath = package.cpath .. ";${luaEnv.luaCpath}"
    '';

  strip = writeText "${pname}-filter" ''
    function unwrap(el)
      return el.content
    end

    return {
      {
        Span = unwrap,
        Div = unwrap,
        Link = function(l)
          return pandoc.Link(l.content, l.target)
        end,
        Header = function(h)
          return pandoc.Header(h.level, h.content)
        end,
        Code = function(c)
          return pandoc.Code(c.text)
        end,
        CodeBlock = function(c)
          local cls = #c.classes == 0 and pandoc.List({ "unk" }) or c.classes
          return pandoc.CodeBlock(c.text, pandoc.Attr(c.identifier, cls))
        end,
      },
    }
  '';

  split = writers.writeLuaBin lua "${pname}-split-filter.lua"
    {
      inherit libraries; doCheck = "lua54+pandoc";
    } ''
    local tokenization = require("tokenizer.tokenization")

    local function patcher(toreplace)
      local space = 0
      local replacement = 1

      local function patch(el)
        space = space + 1
        if space == toreplace[replacement] then
          replacement = replacement + 1
          return pandoc.Str("\n")
        end
        return el
      end

      return {
        -- traverse = 'topdown',
        Space = patch,
        SoftBreak = patch,
      }
    end

    local function trackspace(spaces)
      local function track(el)
        spaces[1] = spaces[1] + 1
        return el
      end

      return {
        traverse = "topdown",
        Space = track,
        SoftBreak = track,
      }
    end

    local function tokenize(el)
      local tokens = tokenization.sentence_tokenize(pandoc.utils.stringify(el.content))
      local toreplace = pandoc.List()

      local i = 0
      for tok in tokens do
        if i > 0 then
          i = i + 1
          toreplace:insert(i)
        end
        local spaces = { 0 }
        pandoc.Inlines(tok):walk(trackspace(spaces))
        i = i + spaces[1]
      end

      el.content = el.content:walk(patcher(toreplace))
      return el
    end

    return {
      {
        Para = tokenize,
        Plain = tokenize,
      },
    }
  '';

  script = writers.writeZshBin "${pname}" ''
    convertPandoc() {
      zparseopts -D -E -F -- \
        -pandoc-extra-arg+:=pandoc_extra P+:=pandoc_extra \
        -grid-tables=opt_grid_tables G=opt_grid_tables \
        -no-split=opt_no_split S=opt_no_split \
        -markdown=opt_markdown m=opt_markdown

      local FROM="$( (( #opt_markdown )) && echo "markdown" || echo "html" )"
      local GRID_TABLES="$( (( #opt_grid_tables )) && echo "" || echo "-grid_tables" )"

      local no_split="$( (( #opt_no_split )) && echo "" || echo "-no_split" )"

      local -a PANDOC_ARGS=(
        -r''${FROM} -wmarkdown-smart-simple_tables-multiline_tables''${GRID_TABLES}
        --data-dir=${initLua}
        --wrap=none --lua-filter=${strip}
      )

      if ! (( #opt_no_split )); then
        PANDOC_ARGS+=(--lua-filter=${lib.getExe split})
      fi

      local PANDOC_EXTRA_SIGIL=(--pandoc-extra-arg -P)
      PANDOC_ARGS+=("''${(@)pandoc_extra:|PANDOC_EXTRA_SIGIL}")

      ${pandoc}/bin/pandoc "''${(@)PANDOC_ARGS}" </dev/stdin
    }

    convertPandoc "$@"
  '';
in
lib.standalone {
  inherit version script;
  passthru = { inherit initLua strip split; };
}
