{ lib
, fetchFromGitHub
, python3Packages
}:
let

  pname = "typepy";
  version = "1.2.0";
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    name = "${name}-src";
    owner = "thombashi";
    repo = pname;
    rev = "83fe150fb6135930c167322137c2c329363920ad";
    hash = "sha256-GljfbJZT1PK//jt+J+QfiqP0/5p9B9y6VKDSB/++nt4=";
  };

in
python3Packages.buildPythonPackage {
  inherit pname version src;

  doCheck = false;

  propagatedBuildInputs = builtins.attrValues {
    inherit (python3Packages)
      mbstrdecoder
      # datetime optional packages
      packaging
      python-dateutil
      pytz
      ;
  };

  meta = {
    description = "A Python library for variable type checker/validator/converter at a run time";
    license = lib.licenses.mit;
  };
}
