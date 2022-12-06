{ lib
, fetchFromGitHub
, python3Packages
}:
let

  pname = "appconfigpy";
  version = "1.0.2";
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    name = "${name}-src";
    owner = "thombashi";
    repo = pname;
    rev = "71aaa3110341ede8706a213cb1eb018a654ca8a6";
    hash = "sha256-m2EyonJxzV0bqNmczcG14d1NAlrA9YvazFLZ+u/bu/A=";
  };

in
python3Packages.buildPythonPackage {
  inherit pname version src;

  doCheck = false;

  meta = {
    description = "A Python library to create/load an application configuration file";
    license = lib.licenses.mit;
  };
}
