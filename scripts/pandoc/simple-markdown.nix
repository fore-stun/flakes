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

  script = writers.writeZshBin "${pname}" ''
    convertPandoc() {
      zparseopts -D -E -F -- \
        -pandoc-extra-arg+:=pandoc_extra P+:=pandoc_extra \
        -grid-tables=opt_grid_tables G=opt_grid_tables \
        -markdown=opt_markdown m=opt_markdown

      local FROM="$( (( #opt_markdown )) && echo "markdown" || echo "html" )"
      local GRID_TABLES="$( (( #opt_grid_tables )) && echo "" || echo "-grid_tables" )"

      local -a PANDOC_ARGS=(
        -r''${FROM} -wmarkdown-smart-simple_tables-multiline_tables''${GRID_TABLES}
        --data-dir=${initLua}
        --wrap=none --lua-filter=${strip}
      )

      local PANDOC_EXTRA_SIGIL=(--pandoc-extra-arg -P)
      PANDOC_ARGS+=("''${(@)pandoc_extra:|PANDOC_EXTRA_SIGIL}")

      ${pandoc}/bin/pandoc "''${(@)PANDOC_ARGS}" </dev/stdin
    }

    convertPandoc "$@"
  '';
in
lib.standalone {
  inherit version script;
  passthru = { inherit initLua strip; };
}
