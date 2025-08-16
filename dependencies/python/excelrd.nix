{ lib
, fetchFromGitHub
, python3Packages
}:
let

  pname = "excelrd";
  version = "2.0.3";
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    name = "${name}-src";
    owner = "thombashi";
    repo = pname;
    rev = "f48958517451301c24fb470bcb6b4f684145f91b";
    hash = "sha256-wcEnzzLVffFyFt+4T1RogRUsWOl8wbGEn/Pi6qY3auQ=";
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

  meta = {
    description = "A modified version of xlrd to work for the latest Python versions";
    license = lib.licenses.mit;
  };
}
