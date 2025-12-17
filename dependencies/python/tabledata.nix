{ lib
, fetchFromGitHub
, python3Packages
}:
let

  pname = "tabledata";
  version = "1.3.0";
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    name = "${name}-src";
    owner = "thombashi";
    repo = pname;
    rev = "8b6369c3e2114597e9cbbebc0f3c3eac77041561";
    hash = "sha256-OMrK0ZrNJ6U7Hxi8LJfUOM2c4YbDJninXFAIiMKHw58=";
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
      dataproperty
      typepy
      ;
  };

  meta = {
    description = "Python library to represent tabular data";
    license = lib.licenses.mit;
  };
}
