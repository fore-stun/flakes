{ lib
, fetchFromGitHub
, python3Packages
}:
let

  pname = "mbstrdecoder";
  version = "1.1.1";
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    name = "${name}-src";
    owner = "thombashi";
    repo = pname;
    rev = "2e652d7d18ba9a16be5685f3625eac1f1f1c64b6";
    hash = "sha256-U8F+mWKDulIRvvhswmdGnxKjM2qONQybViQ5TLZbLDY=";
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
      chardet
      ;
  };

  meta = {
    description = "Python library for multi-byte character string decoder";
    license = lib.licenses.mit;
  };
}
