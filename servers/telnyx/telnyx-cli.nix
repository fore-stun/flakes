{ lib
, buildGoModule
, fetchFromGitHub
, installShellFiles
}:

let
  version = "0.32.0";
  pname = "telnyx-cli";
  mainProgram = "telnyx";

in
buildGoModule {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "team-telnyx";
    repo = pname;
    name = "${pname}-${version}-source";
    rev = "v${version}";
    hash = "sha256-A80gU+P42VZhYxg/TE2RfFWeVpcV+aI7liCkbuSx1AM=";
  };

  vendorHash = "sha256-1knW/g3FDMMME0RmF+JB0GrWQSOTH9P9ss5iEoiVops=";

  subPackages = [ "cmd/telnyx" ];

  ldflags = [ "-s" "-w" ];

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    installShellCompletion --cmd "${mainProgram}" \
      --bash <($out/bin/${mainProgram} @completion bash) \
      --zsh <($out/bin/${mainProgram} @completion zsh) \
      --fish <($out/bin/${mainProgram} @completion fish)
  '';

  meta = {
    description = "Official CLI SDK for the Telnyx REST API";
    homepage = "https://github.com/team-telnyx/telnyx-cli";
    changelog = "https://github.com/team-telnyx/telnyx-cli/releases/tag/v${version}";
    license = lib.licenses.mit;
    inherit mainProgram;
  };
}
