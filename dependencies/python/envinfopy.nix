{ lib
, fetchFromGitHub
, python3Packages
}:
let

  pname = "envinfopy";
  version = "0.0.7";
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    name = "${name}-src";
    owner = "thombashi";
    repo = pname;
    rev = "0b68476d152e52d83ec349768c0d7b4502cbc3d3";
    hash = "sha256-9b2j+gZ3P8QXbZZxw0Itep4zqgprfmTNqtFDPd5qC6A=";
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
    description = "A Python Library to get execution environment information";
    license = lib.licenses.mit;
  };
}
