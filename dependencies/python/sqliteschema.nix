{ lib
, fetchFromGitHub
, python3Packages
}:
let

  pname = "sqliteschema";
  version = "1.3.0";
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    name = "${name}-src";
    owner = "thombashi";
    repo = pname;
    rev = "c599ca889658f3080fbf900110a3edb0541a6d35";
    hash = "sha256-17MQkvMQo0b08+MEbVFsWdX6w2cYnr/NpKWAxeFnP+0=";
  };

in
python3Packages.buildPythonPackage {
  inherit pname version src;

  doCheck = false;

  propagatedBuildInputs = builtins.attrValues {
    inherit (python3Packages)
      mbstrdecoder
      tabledata
      typepy
      ;
  };

  meta = {
    description = "Python library to dump table schema of a SQLite database file";
    license = lib.licenses.mit;
  };
}
