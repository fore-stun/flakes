{ lib
, fetchFromGitHub
, python3Packages
}:
let

  pname = "pytablereader";
  version = "0.31.4";
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    name = "${name}-src";
    owner = "thombashi";
    repo = pname;
    rev = "b2a6a3db3ef52f5db942340ae75a6905df64a960";
    hash = "sha256-SxYP6JT7r9udUFh6ZADvKmMMnvFcStFx8qelK8pmsZ0=";
  };

in
python3Packages.buildPythonPackage {
  inherit pname version src;

  doCheck = false;

  pyproject = true;
  build-system = builtins.attrValues {
    inherit (python3Packages)
      setuptools
      ;
  };

  prePatch = ''
    substituteInPlace requirements/requirements.txt --replace \
      "path>=13,<17" \
      "path>=13,<18"
  '';

  propagatedBuildInputs = builtins.attrValues {
    inherit (python3Packages)
      beautifulsoup4
      dataproperty
      pathvalidate
      path
      tabledata
      typepy
      jsonschema
      # md optional dependencies
      markdown
      # excel optional dependencies
      excelrd
      # sqlite optional dependencies
      simplesqlite
      # url optional dependencies
      retryrequests
      ;
  };

  meta = {
    description = "A Python library to load structured table data from files/strings/URL with various data format: CSV / Excel / Google-Sheets / HTML / JSON / LDJSON / LTSV / Markdown / SQLite / TSV";
    license = lib.licenses.mit;
  };
}
