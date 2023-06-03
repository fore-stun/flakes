{ lib
, buildDotnetModule
, dotnetCorePackages
, fetchFromGitHub
, makeWrapper
}:

let
  pname = "fsharp-language-server";
  version = "unstable-2022-10-21";
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    name = "${name}-src";
    owner = "fsprojects";
    repo = pname;
    rev = "989490a77a07f34c7b14ce1f5258852d6beb59f0";
    hash = "sha256-ph+N0gmJTCxfsKgA3FyIP7KSYZ4u8sKpHoYWKyXqSY8=";
  };

  # Need to add the following to the fetch-deps script.
  # projectFiles+=( "src/csharp-language-server.sln" )
  projectFile = "fsharp-language-server.sln";

  module =
    buildDotnetModule {
      inherit pname version src;

      nugetDeps = builtins.path {
        name = "${pname}-deps.nix";
        path = ./fsharp-language-server-deps.nix;
      };

      dotnet-sdk = dotnetCorePackages.sdk_8_0;
      dotnet-runtime = dotnetCorePackages.aspnetcore_8_0;
      inherit projectFile;

      # executables = [ "CSharpLanguageServer" ];

      # postInstall = ''
      #   makeWrapper "$out/lib/${pname}/CSharpLanguageServer" "$out/bin/${pname}" \
      #     --argv0 "${pname}" \
      #     --set-default DOTNET_ROOT "${dotnetCorePackages.aspnetcore_7_0}/"
      # '';

      meta = {
        description = "F# language server using Language Server Protocol";
        license = lib.licenses.mit;
      };
    };

in
module
