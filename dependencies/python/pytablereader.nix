{ lib
, fetchFromGitHub
, python3Packages
}:
let

  pname = "pytablereader";
  version = "0.31.3";
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    name = "${name}-src";
    owner = "thombashi";
    repo = pname;
    rev = "b59859da6fdcc94035933dd253e6e380b04a233b";
    hash = "sha256-iuAvdWw+0XVmBHs/90zEVw5FhHQjr1O3efDNK1LQzig=";
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
