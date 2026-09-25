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

  hashes = {
    "macos-arm64" = "sha256-RMrZ7ity6S0kF+VtBOEmLHeCXu/DB55W9EkwrtufQqM=";
    "linux-amd64" = "sha256-O04CC8LlePCo10e0MJ4q2E0CKjijrW1UTaEZZ64Wbss=";
  };

  mkSrc = { os, arch, hash ? lib.fakeHash }: fetchurl {
    url = "https://github.com/team-telnyx/edge-compute/releases/download/v${version}/telnyx-edge-v${version}-${os}-${arch}.tar.gz";
    name = "${pname}-${version}-${os}-${arch}.tar.gz";
    hash = if hash == null then hashes."${os}-${arch}" or lib.fakeHash else hash;
  };

  update-hashes = stdenv.mkDerivation {
    pname = "${pname}-update-hashes";
    inherit version;

    srcs = lib.mapAttrsToList
      (system: _:
        let sys = lib.strings.splitString "-" system;
        in mkSrc { os = builtins.elemAt sys 0; arch = builtins.elemAt sys 1; })
      hashes;

    dontUnpack = true;
    installPhase = ''
      touch $out
    '';
  };
in
stdenv.mkDerivation {
  inherit pname version;

  src = mkSrc { inherit os arch; hash = null; };

  passthru = {
    inherit update-hashes;
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
