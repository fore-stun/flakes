{ lib
, writers
, python3
, python3Packages
}:

let
  # Vendored from pkgs/build-support/writers/default.nix
  # I’ve added the `doCheck` flag
  # makePythonWriter takes python and compatible pythonPackages and produces python script writer,
  # which validates the script with flake8 at build time. If any libraries are specified,
  # python.withPackages is used as interpreter, otherwise the "bare" python is used.
  makePythonWriter =
    python: pythonPackages: name:
    { libraries ? [ ]
    , flakeIgnore ? [ ]
    , doCheck ? false
    }:
    let
      inherit (lib) concatMapStringsSep escapeShellArg optionalString;
      inherit (writers) makeScriptWriter writeDash;
      ignoreAttribute = optionalString (flakeIgnore != [ ]) "--ignore ${concatMapStringsSep "," escapeShellArg flakeIgnore}";
    in
    makeScriptWriter
      {
        interpreter =
          if libraries == [ ]
          then "${python}/bin/python"
          else "${python.withPackages (ps: libraries)}/bin/python"
        ;
        ${if doCheck then "check" else null} = writeDash "python2check.sh" ''
          exec ${pythonPackages.flake8}/bin/flake8 --show-source ${ignoreAttribute} "$1"
        '';
      }
      name;

in
name:

makePythonWriter python3 python3Packages "/bin/${name}"
