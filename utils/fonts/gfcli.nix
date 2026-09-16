{ lib
, buildNpmPackage
, fetchFromGitHub
}:

let
  pname = "gfcli";
  owner = "t2sever";
  repo = pname;
  version = "3.2.1";

  src = fetchFromGitHub {
    inherit owner repo;
    # rev = "v${version}";
    rev = "fe9470776ef9722daef03227fa09668ca6c71198";
    hash = "sha256-cEt0eH9wiwCklEuYbR4RnVBNfcHJKr6OXirCvcta2GQ=";
  };
in

buildNpmPackage {
  inherit pname src version;

  dontNpmBuild = true;

  npmDepsHash = "sha256-Dy1la0NMbX1sGwRLoNX89tfFobQARh1Zevmb1o/HvtU=";

  meta = with lib; {
    description = "Simple Google Font CLI and NPM package.";
    homepage = "https://s.tin-sever.de/gfcli/";
    license = licenses.mit;
    platforms = platforms.all;
    mainProgram = pname;
  };
}
