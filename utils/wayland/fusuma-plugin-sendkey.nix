{ lib
, bundlerApp
, gnugrep
, libinput
, makeWrapper
}:

let
  pname = "fusuma-plugin-sendkey";
  owner = "iberianpig";

  mainProgram = "fusuma-sendkey";

  repo = pname;

in
bundlerApp {
  inherit pname;

  gemdir = builtins.path {
    name = pname;
    path = ./. + "/${pname}";
  };

  exes = [ mainProgram ];

  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    wrapProgram "$out/bin/${mainProgram}" \
      --prefix PATH : ${lib.makeBinPath [ gnugrep libinput ]}
  '';

  meta = {
    description = "A Fusuma plugin for sending virtual key events";
    homepage = "https://github.com/${owner}/${repo}";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    inherit mainProgram;
  };
}
