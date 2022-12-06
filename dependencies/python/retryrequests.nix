{ lib
, fetchFromGitHub
, python3Packages
}:
let

  pname = "retryrequests";
  version = "0.2.0";
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    name = "${name}-src";
    owner = "thombashi";
    repo = pname;
    rev = "b63a008da2e7cadc1fb2039b6912dc6bcb7345c0";
    hash = "sha256-bla17VebkQlga6K+yGAd+XUxXz0Oh4Kem4i6tq29QxQ=";
  };

in
python3Packages.buildPythonPackage {
  inherit pname version src;

  doCheck = false;

  propagatedBuildInputs = builtins.attrValues {
    inherit (python3Packages)
      requests
      ;
  };

  meta = {
    description = "A Python library that make HTTP requests with exponential back-off retry by using requests package";
    license = lib.licenses.mit;
  };
}
