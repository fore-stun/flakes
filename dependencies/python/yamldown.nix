{ lib
, fetchFromGitHub
, python3Packages
}:
let

  pname = "yamldown";
  version = "0.1.8";
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    name = "${name}-src";
    owner = "dougli1sqrd";
    repo = pname;
    rev = "07a3943ac38954b2e37f8ac57ccfe0ecaaf0f560";
    hash = "sha256-5gVXv56x4VznNvXZdnXMOcxbcEhZvZoIf5WUTzQIO0M=";
  };

in
python3Packages.buildPythonPackage {
  inherit pname version src;

  propagatedBuildInputs = builtins.attrValues {
    inherit (python3Packages)
      pyyaml
      ;
  };

  meta = {
    description = "Python library for loading and dumping “yamldown” (markdown with embedded yaml) files.";
    license = lib.licenses.bsd3;
  };
}
