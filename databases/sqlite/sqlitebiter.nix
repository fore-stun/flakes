{ lib
, fetchFromGitHub
, python3Packages
}:
let

  pname = "sqlitebiter";
  version = "0.36.3";
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    name = "${name}-src";
    owner = "thombashi";
    repo = pname;
    rev = "d86ce6c2bad4aea8379b5ef5ed08b2621b4ce122";
    hash = "sha256-u/CDQP66r10c2fwIhaam9aBrz1BC7g+g9IjlZ70qsrE=";
  };

in
python3Packages.buildPythonPackage {
  inherit pname version src;

  pyproject = true;
  build-system = builtins.attrValues {
    inherit (python3Packages)
      setuptools
      ;
  };

  doCheck = false;

  prePatch = ''
    substituteInPlace requirements/requirements.txt --replace \
      "path>=13,<17" \
      "path>=13,<18"
  '';

  propagatedBuildInputs = builtins.attrValues {
    inherit (python3Packages)
      appconfigpy
      click
      envinfopy
      loguru
      msgfy
      nbformat
      path
      pytablereader
      retryrequests
      simplesqlite
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
