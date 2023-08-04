{ lib
, fetchFromGitHub
, python3Packages
}:
let

  pname = "sqlitebiter";
  version = "0.36.1";
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    name = "${name}-src";
    owner = "thombashi";
    repo = pname;
    rev = "d0b5fa2d8a422b4834a37dd710724f6e4b19aedd";
    hash = "sha256-PqwYLAN9KznlQiTYSTvZHuncSx/kUQzdC6IqOTE5XnU=";
  };

in
python3Packages.buildPythonPackage {
  inherit pname version src;

  doCheck = false;

  propagatedBuildInputs = builtins.attrValues {
    inherit (python3Packages)
      SimpleSQLite
      appconfigpy
      click
      envinfopy
      loguru
      msgfy
      nbformat
      path
      pytablereader
      retryrequests
      tcolorpy
      typepy
      ;
  };

  meta = {
    description = "A CLI tool to convert CSV / Excel / HTML / JSON / Jupyter Notebook / LDJSON / LTSV / Markdown / SQLite / SSV / TSV / Google-Sheets to a SQLite database file";
    license = lib.licenses.mit;
    mainProgram = pname;
  };
}
