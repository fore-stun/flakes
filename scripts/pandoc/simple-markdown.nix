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

  renumber = writers.writeLuaBin lua "${pname}-renumber-filter.lua"
    {
      inherit libraries; doCheck = "lua54+pandoc";
    } ''
    -- renumber.lua
    --
    -- Renumbers top-level ordered lists so numbering continues sequentially
    -- across the whole document/selection (list 2 picks up where list 1 left
    -- off), instead of every OrderedList restarting at 1. Ordered lists
    -- nested inside list items are left completely untouched.
    --
    -- Usage:
    --   pandoc --lua-filter=renumber.lua -f markdown -t markdown -s input.md -o output.md
    --
    -- How it avoids mixing up nesting levels:
    --   Pandoc's *default* filter traversal ("typewise") visits every Block
    --   of a given type in one flat pass, with no reliable parent-before-child
    --   ordering guarantee among Blocks of the same type. That means a naive
    --   filter keyed only on list style/delimiter can't tell a top-level list
    --   apart from one nested three levels deep.
    --   The fix: use `traverse = 'topdown'` and, on matching a top-level
    --   OrderedList, return `(new_list, false)`. Returning `false` as the
    --   second value tells Pandoc to NOT descend into that element's
    --   children -- so nested OrderedLists inside its items are never handed
    --   to this same OrderedList function, and therefore can never be
    --   mistaken for siblings at the top level. (Confirmed against Pandoc's
    --   documented topdown short-circuit behaviour.)

    local next_starts = {}

    local function list_key(ol)
      return tostring(ol.style) .. '|' .. tostring(ol.delimiter)
    end

    local filter = {
      traverse = 'topdown',

      OrderedList = function(ol)
        local key = list_key(ol)
        ol.start = next_starts[key] or 1
        next_starts[key] = ol.start + #ol.content

        -- `false` stops Pandoc descending into ol's items, so nested
        -- ordered lists inside this list are left exactly as they were
        -- and never seen by this function.
        return ol, false
      end,
    }

    function Pandoc(doc)
      doc.blocks = doc.blocks:walk(filter)
      return doc
    end
  '';

  split = writers.writeLuaBin lua "${pname}-split-filter.lua"
    {
      inherit libraries; doCheck = "lua54+pandoc";
    } ''
    package.loaded["rex_pcre"] = require("rex_pcre2")

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

  tac = writers.writeLuaBin lua "${pname}-tac-filter.lua"
    {
      inherit libraries; doCheck = "lua54+pandoc";
    } ''
    function Pandoc(doc)
      local blocks = doc.blocks
      local n = #blocks
      local reversed = {}
      for i = n, 1, -1 do
        reversed[#reversed + 1] = blocks[i]
      end
      return pandoc.Pandoc(reversed, doc.meta)
    end
  '';

  script = writers.writeZshBin "${pname}" ''
    convertPandoc() {
      zparseopts -D -E -F -- \
        -pandoc-extra-arg+:=ARG_pandoc_extra P+:=ARG_pandoc_extra \
        -grid-tables=OPT_grid_tables G=OPT_grid_tables \
        -reference-links=OPT_reference_links R=OPT_reference_links \
        -no-split=OPT_no_split S=OPT_no_split \
        -tac=OPT_tac T=OPT_tac \
        -markdown=OPT_markdown m=OPT_markdown \
        -dry-run=OPT_dry_run n=OPT_dry_run

      local FROM="$( (( #OPT_markdown )) && echo "markdown" || echo "html" )"
      local GRID_TABLES="$( (( #OPT_grid_tables )) && echo "" || echo "-grid_tables" )"

      local no_split="$( (( #OPT_no_split )) && echo "" || echo "-no_split" )"

      local -a pandoc_markdown_extensions=(
        -smart
        -simple_tables
        -multiline_tables
        ''${GRID_TABLES}
      )

      local -a pandoc_args=(
        -r''${FROM} -wmarkdown''${(j::)pandoc_markdown_extensions}
        --data-dir=${initLua}
        --wrap=none --lua-filter=${strip}
      )

      if (( #OPT_tac )); then
        pandoc_args+=(--lua-filter=${lib.getExe tac})
      fi

      if ! (( #OPT_no_split )); then
        pandoc_args+=(--lua-filter=${lib.getExe split})
      fi

      if (( #OPT_reference_links )); then
        pandoc_args+=(--reference-links=true)
      fi

      local PANDOC_EXTRA_SIGIL=(--pandoc-extra-arg -P)
      pandoc_args+=("''${(@)ARG_pandoc_extra:|PANDOC_EXTRA_SIGIL}")

      if (( $#OPT_dry_run )); then
        print -- ${lib.getExe pandoc} "''${(@)pandoc_args}" '<&0' >&2
        return 0
      fi

      ${lib.getExe pandoc} "''${(@)pandoc_args}" <&0
    }

    convertPandoc "$@"
  '';
in
lib.standalone {
  inherit version script;
  passthru = { inherit initLua strip split tac; };
}
