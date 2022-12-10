{ lib
, buildDotnetModule
, fetchFromGitHub
, glibcLocales
}:

let
  pname = "marksman";
  version = "2022-11-25";
  name = "${pname}-${version}";
  rev = "0ad3341528a75971e78bf35576d47e2c54822abf";

  src = fetchFromGitHub {
    name = "${name}-src";
    owner = "artempyanykh";
    repo = pname;
    inherit rev;
    hash = "sha256-f5vbYp+7Ez96lbK0yvPekt3W3X6kKPXO6Lowb+hLLsc=";
  };

in
buildDotnetModule {
  inherit pname version src;

  LOCALE_ARCHIVE = "${glibcLocales}/lib/locale/locale-archive";

  postPatch = ''
    substituteInPlace ./Marksman/Marksman.fsproj \
      --replace 'git describe --always --dirty' 'echo ${rev}'
  '';

  nugetDeps = ./marksman-deps.nix;

  executables = [ "marksman" ];

  meta = {
    description = "Write Markdown with code assist and intelligence in the comfort of your favourite editor";
    license = lib.licenses.mit;
  };
}
