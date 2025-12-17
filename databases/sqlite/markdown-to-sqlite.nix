{ lib
, fetchFromGitHub
, python3Packages
}:
let

  pname = "markdown-to-sqlite";
  version = "1.0";
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    name = "${name}-src";
    owner = "simonw";
    repo = pname;
    rev = "7381ff6a9a301aacad6d58fb4e92bcae72e896ab";
    hash = "sha256-TVZsDpqrdqmfpASNFL90ldEcjHmNK27flJJS9irw520=";
  };

in
python3Packages.buildPythonPackage {
  inherit pname version src;

  pyproject = true;
  build-system = builtins.attrValues {
    inherit (python3Packages)
      setuptools
      ;
  };

  doCheck = false;

  propagatedBuildInputs = builtins.attrValues {
    inherit (python3Packages)
      click
      markdown
      sqlite-utils
      yamldown
      ;
  };

  meta = {
    description = "CLI tool for loading markdown files into a SQLite database";
    license = lib.licenses.asl20;
    mainProgram = pname;
  };
}
