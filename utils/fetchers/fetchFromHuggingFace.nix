{ lib
, huggingface-model-downloader
, stdenvNoCC
}:

{ model
, version
, hash ? null
, requireToken ? false
, extraArgs ? [ ]
}:

stdenvNoCC.mkDerivation {
  pname = "hf-${lib.replaceStrings ["/"] ["-"] model}";
  inherit version;

  dontUnpack = true;
  dontFixup = true;

  impureEnvVars = [ "HUGGING_FACE_HUB_TOKEN" ];

  nativeBuildInputs = [
    huggingface-model-downloader
  ];

  preBuild = lib.optionalString requireToken ''
    if [ -z ''${HUGGING_FACE_HUB_TOKEN} ]; then
      echo "Private: fetchFromHuggingFace requires the nix building process (nix-daemon in multi user mode) to have the HUGGING_FACE_HUB_TOKEN env var set." >&2
      exit 1
    fi
  '';

  EXTRA_ARGS = extraArgs;

  buildPhase = ''
    runHook preBuild

    ${lib.getExe huggingface-model-downloader} -m ${model} "''${EXTRA_ARGS[@]}"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    cp -r --reflink=auto . "$out"

    runHook postInstall
  '';

  outputHash = hash;
  outputHashMode = "recursive";
}
