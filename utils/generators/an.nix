{ lib
, aspell
, fetchgit
, hostPlatform
, hunspellDicts
, icu
, makeWrapper
, stdenv
}:

let
  pname = "an";
  version = "0.95";
  src = fetchgit {
    url = "https://salsa.debian.org/pm/an.git";
    rev = "403d9a4fd75a5cfae9d5388c4a0e7f889145177f";
    hash = "sha256-q+TSG+dv6xCCZ7Ta+i0o5BLnP8uxdIFwzZK2kXoaQaQ=";
    leaveDotGit = false;
    deepClone = false;
  };
  meta = {
    description = "Very fast anagram generator";
    homepage = "http://fatphil.org/words/an.html";
    license = lib.licenses.gpl2Plus;
    mainProgram = pname;
  };
in
stdenv.mkDerivation {
  inherit pname version src meta;
  nativeBuildInputs = [ aspell hunspellDicts.en_GB-large icu ];
  buildInputs = [ makeWrapper ];
  postBuild = ''
    mkdir aspellData
    ln -sv "${hunspellDicts.en_GB-large}/share/hunspell/en_GB.aff" aspellData/en_DB.dat
    aspell --lang=en_GB --data-dir=aspellData \
      --encoding=utf-8 expand < "${hunspellDicts.en_GB-large}/share/hunspell/en_GB.dic" \
        | tr " " "\n"
        > english_wordlist.txt
  '';
  preInstall = ''
    mkdir -p "$out/lib"
    mkdir -p "$out/bin"
    mkdir -p "$out/usr/share/man/man6"
  '';
  postInstall = ''
    mv -v english_wordlist.txt "$out/lib/"
    wrapProgram "$out/bin/${pname}" \
      --add-flags "--dict=$out/lib/english_wordlist.txt"
  '';
  buildFlags = lib.optionals hostPlatform.isDarwin [ "CC=clang" ];
  installFlags = [ "DESTDIR=$(out)" "INSTALLDIR=$(out)/bin" ];
}
