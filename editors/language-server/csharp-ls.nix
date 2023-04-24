{ lib
, buildDotnetModule
, dotnetCorePackages
, fetchFromGitHub
, makeWrapper
}:

let
  pname = "csharp-ls";
  version = "0.7.1";
  name = "${pname}-${version}";
  rev = "aebb2c77e4f33a71c803a78b9549a31541894e17";

  src = fetchFromGitHub {
    name = "${name}-src";
    owner = "razzmatazz";
    repo = "csharp-language-server";
    inherit rev;
    hash = "sha256-6ZCbhY4TgfgKn5ofJLh29nuazWlxa4rLK6jzDlm2IwM=";
  };

  # Need to add the following to the fetch-deps script.
  # projectFiles+=( "src/csharp-language-server.sln" )
  projectFile = "src/csharp-language-server.sln";

  overrides = old: {
    passthru.fetch-deps = old.passthru.fetch-deps.overrideAttrs (fd: {
      text = lib.replaceStrings
        [ "projectFiles=(" ] [ "projectFiles=( ${projectFile}" ]
        fd.text;
    });
  };

  module =
    buildDotnetModule {
      inherit pname version src;

      dotnet-sdk = dotnetCorePackages.sdk_7_0;
      dotnet-runtime = dotnetCorePackages.aspnetcore_7_0;
      inherit projectFile;

      executables = [ "CSharpLanguageServer" ];

      postInstall = ''
        makeWrapper "$out/lib/${pname}/CSharpLanguageServer" "$out/bin/${pname}" \
          --argv0 "${pname}" \
          --set-default DOTNET_ROOT "${dotnetCorePackages.aspnetcore_7_0}/"
      '';

      meta = {
        description = "Roslyn-based LSP language server for C♯";
        license = lib.licenses.mit;
      };
    };

in
module.overrideAttrs overrides
