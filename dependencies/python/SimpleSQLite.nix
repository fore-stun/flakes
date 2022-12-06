{ lib
, fetchFromGitHub
, python3Packages
}:
let

  pname = "SimpleSQLite";
  version = "1.3.0";
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    name = "${name}-src";
    owner = "thombashi";
    repo = pname;
    rev = "9ff8825e597dc9c787d486a62ce84d482a2320bc";
    hash = "sha256-nHBlkElyfCoJ/8H8j5qc5f4mMwLUGOBJmKrQ0N0gQzE=";
  };

in
python3Packages.buildPythonPackage {
  inherit pname version src;

  doCheck = false;

  propagatedBuildInputs = builtins.attrValues {
    inherit (python3Packages)
      DataProperty
      mbstrdecoder
      pathvalidate
      sqliteschema
      tabledata
      typepy
      ;
  };

  meta = {
    description = "Python library to simplify SQLite database operations: table creation, data insertion and get data as other data formats";
    license = lib.licenses.mit;
  };
}
