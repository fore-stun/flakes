{ lib
, writers
}:

let
  # Vendored from pkgs/build-support/writers/default.nix
  # I’ve added the `doCheck` flag

  # makeLuaWriter takes lua and compatible luaPackages and produces lua script writer,
  # which validates the script with luacheck at build time. If any libraries are specified,
  # lua.withPackages is used as interpreter, otherwise the "bare" lua is used.
  makeLuaWriter =
    lua: name:
    { libraries ? [ ]
    , doCheck ? false
    }:
    writers.makeScriptWriter
      {
        interpreter =
          if libraries == [ ]
          then lua.interpreter
          else (lua.withPackages (_: libraries)).interpreter
        ;
        ${if doCheck then "check" else null} = writers.writeDash "luacheck.sh" ''
          exec ${lib.getExe lua.pkgs.luacheck} "$1"
        '';
      }
      name;

in
lua: name:

makeLuaWriter lua "/bin/${name}"
