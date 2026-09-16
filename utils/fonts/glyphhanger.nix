{ lib
, brotli
, buildNpmPackage
, fetchFromGitHub
, makeWrapper
, python3
}:

let
  pname = "glyphhanger";
  owner = "zachleat";
  repo = pname;
  version = "6.0.0";

  src = fetchFromGitHub {
    inherit owner repo;
    # rev = "v${version}";
    rev = "3ef6eb43e72ba3cf3aa2452ab648275c4adb8ab1";
    hash = "sha256-g2Eh4zHmDgjKIdUwTIP04ku/8bpaKI4m1mNfzhA6wss=";
  };

  # Runtime dependencies that glyphhanger calls out to in the background
  runtimeDeps = [
    brotli
    (python3.withPackages (ps: with ps; [ fonttools ]))
  ];

in

buildNpmPackage {
  inherit pname runtimeDeps src version;

  npmDepsHash = "sha256-AgAMqM3SwSHyYUC4JH8y2QCx4hc2N5B6N+OihamHmag=";

  nativeBuildInputs = [ makeWrapper ];

  PUPPETEER_SKIP_DOWNLOAD = true;

  dontNpmBuild = true;

  postInstall = ''
    wrapProgram $out/bin/glyphhanger \
      --prefix PATH : ${lib.makeBinPath runtimeDeps} \
      --append-flags "--jsdom"
  '';

  meta = with lib; {
    description = "Your web font utility belt. It can subset web fonts. It can find unicode-ranges for you automatically. It makes julienne fries.";
    homepage = "https://github.com/${owner}/${repo}";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = pname;
    platforms = platforms.all;
  };
}
