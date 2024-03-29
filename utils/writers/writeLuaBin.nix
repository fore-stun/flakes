{ lib
, writeText
, writers
}:

let
  luacheckConfig = writeText "luacheckrc" ''
    stds.luacheckrc = { globals = {
      std = {},
    } }

    local pandoc_shared = {
      read_globals = {
        pandoc = { other_fields = true },
        PANDOC_STATE = { other_fields = true },
      },
    }

    stds.pandoc = pandoc_shared

    stds.pandocWriter = {
      read_globals = pandoc_shared.read_globals,
      globals = {
        Writer = { other_fields = true },
      },
    }
  '';

  # Vendored from pkgs/build-support/writers/default.nix
  # I’ve added the `doCheck` flag

  # makeLuaWriter takes lua and compatible luaPackages and produces lua script writer,
  # which validates the script with luacheck at build time. If any libraries are specified,
  # lua.withPackages is used as interpreter, otherwise the "bare" lua is used.
  makeLuaWriter =
    lua: name:
    { libraries ? [ ]
    , doCheck ? null
    }:
    writers.makeScriptWriter
      {
        interpreter =
          if libraries == [ ]
          then lua.interpreter
          else (lua.withPackages (_: libraries)).interpreter
        ;
        ${if lib.isString doCheck then "check" else null} = writers.writeDash "luacheck.sh" ''
          exec ${lib.getExe lua.pkgs.luacheck} --config "${luacheckConfig}" --std "${doCheck}" "$1"
        '';
      }
      name;

in
lua: name:

makeLuaWriter lua "/bin/${name}"
