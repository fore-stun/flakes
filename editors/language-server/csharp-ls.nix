{ lib
, buildDotnetModule
, dotnetCorePackages
, fetchFromGitHub
, makeWrapper
}:

let
  pname = "csharp-ls";
  version = "0.8.0";
  name = "${pname}-${version}";
  rev = "df4a17901ce0c69076708a09a9d016f362dc7164";

  src = fetchFromGitHub {
    name = "${name}-src";
    owner = "razzmatazz";
    repo = "csharp-language-server";
    inherit rev;
    hash = "sha256-JIUYlvZ+9XnisRIgPm0lWsUvgnudUY19rL81iX0Utd4=";
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

      nugetDeps = builtins.path {
        name = "${pname}-deps.nix";
        path = ./csharp-ls-deps.nix;
      };

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
