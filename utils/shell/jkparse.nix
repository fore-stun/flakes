{ lib
, fetchFromGitHub
, hostPlatform
, json_c
, stdenv
, zsh
}:

let
  pname = "jkparse";
  version = "unstable-2024-02-12";
  owner = "jacre8";
  src = fetchFromGitHub {
    inherit owner;
    repo = pname;
    rev = "cd4d5f4984ba4ef5d973b5f3b25b05d38a60f899";
    hash = "sha256-Xn02RhupEIlp2PO3zofAKITnSWgf5bPhXYG47Qc1gFM=";
  };
  meta = {
    description = "JSON parser for shell scripts that utilizes the (associative) array capabilities of bash, ksh, zsh, and similar shells. Uses the json-c library.";
    homepage = "https://github.com/${owner}/${pname}";
    license = lib.licenses.gpl2;
    mainProgram = pname;
  };
in
stdenv.mkDerivation {
  inherit pname version src meta;
  buildInputs = [ json_c ];
  makeFlags = [ "USE_SHELL_PRINTF=${lib.getExe zsh}" ];
  buildFlags = lib.optionals hostPlatform.isDarwin [ "CC=clang" ];
  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin"

    install -m0755 "bin/jkparse" "$out/bin"
    install -m0755 "libjkparse.sh" "$out/bin/libjkparse"

    runHook postInstall
  '';
}
