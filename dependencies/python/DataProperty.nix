{ lib
, fetchFromGitHub
, python3Packages
}:
let

  pname = "DataProperty";
  version = "0.55.0";
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    name = "${name}-src";
    owner = "thombashi";
    repo = pname;
    rev = "539d0a1d1b4b9ffcb6681c2d67d512f90eae5cf5";
    hash = "sha256-ODSrKZ8M/ni9r2gkVIKWaKkdr+3AVi4INkEKJ+cmb44=";
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
      mbstrdecoder
      typepy
      ;
  };

  meta = {
    description = "A Python library for extract property from data";
    license = lib.licenses.mit;
  };
}
