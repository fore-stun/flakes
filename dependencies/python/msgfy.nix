{ lib
, fetchFromGitHub
, python3Packages
}:
let

  pname = "msgfy";
  version = "0.2.0";
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    name = "${name}-src";
    owner = "thombashi";
    repo = pname;
    rev = "63e1bcef4cbeb4f96e26eef1b80d017e8ff2d8d5";
    hash = "sha256-UZWg8qat3ATomAImNp9e8pfrtYnuKeNEpr36ewFq0Ms=";
  };

in
python3Packages.buildPythonPackage {
  inherit pname version src;

  doCheck = false;

  propagatedBuildInputs = builtins.attrValues {
    inherit (python3Packages)
      chardet
      ;
  };

  meta = {
    description = "A Python library for convert Exception instance to a human-readable error message";
    license = lib.licenses.mit;
  };
}
