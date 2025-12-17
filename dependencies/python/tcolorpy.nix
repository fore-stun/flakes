{ lib
, fetchFromGitHub
, python3Packages
}:
let

  pname = "tcolorpy";
  version = "0.1.2";
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    name = "${name}-src";
    owner = "thombashi";
    repo = pname;
    rev = "62280b8ab1b53e90835a480f4a28b712c9e18704";
    hash = "sha256-duMbeKygEuGVcg4+gQRfClww3rs5AsmJR1VQBo7KWFY=";
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
    description = "A Python library to apply true color for terminal text";
    license = lib.licenses.mit;
  };
}
