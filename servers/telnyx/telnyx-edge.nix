{ lib
, autoPatchelfHook
, fetchurl
, installShellFiles
, stdenv
, makeBinaryWrapper
}:

let
  pname = "telnyx-edge";
  mainProgram = pname;
  version = "0.5.4";

  os =
    if stdenv.hostPlatform.isLinux then "linux"
    else if stdenv.hostPlatform.isDarwin then "macos"
    else throw "telnyx-edge: unsupported OS ${stdenv.hostPlatform.system}";

  arch =
    if stdenv.hostPlatform.isx86_64 then "amd64"
    else if stdenv.hostPlatform.isAarch64 then "arm64"
    else throw "telnyx-edge: unsupported arch ${stdenv.hostPlatform.system}";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://github.com/team-telnyx/edge-compute/releases/download/v${version}/telnyx-edge-v${version}-${os}-${arch}.tar.gz";
    name = "${pname}-${version}-${os}-${arch}.tar.gz";
    hash = "sha256-RMrZ7ity6S0kF+VtBOEmLHeCXu/DB55W9EkwrtufQqM=";
  };

  nativeBuildInputs = [
    installShellFiles
    makeBinaryWrapper
  ] ++ lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 "${mainProgram}" "$out/bin/${mainProgram}"
    wrapProgram "$out/bin/${mainProgram}" \
      --set TELNYX_NO_UPDATE_CHECK 1

    runHook postInstall
  '';

  dontStrip = true;
  doInstallCheck = false;

  meta = {
    description = "Edge Compute CLI tool: scaffold, deploy, and manage Telnyx edge functions";
    homepage = "https://github.com/team-telnyx/edge-compute";
    changelog = "https://github.com/team-telnyx/edge-compute/releases/tag/v${version}";
    sourceProvenance = builtins.attrValues {
      inherit (lib.sourceTypes) binaryNativeCode;
    };
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    inherit mainProgram;
  };
}
