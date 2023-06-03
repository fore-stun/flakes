{ lib
, buildDotnetModule
, dotnetCorePackages
, fetchFromGitHub
, makeWrapper
}:

let
  pname = "fsautocomplete";
  version = "0.59.6";
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    name = "${name}-src";
    owner = "fsharp";
    repo = "FsAutoComplete";
    rev = "549607397090b8e256bb99c56871795233d02f27";
    hash = "sha256-ttmWNQIyE1SC1Mrdy/LsPlQPRWRApMGVHKEmQXILFGA=";
  };

  # Need to add the following to the fetch-deps script.
  # projectFiles+=( "src/csharp-language-server.sln" )
  projectFile = "FsAutoComplete/FsAutoComplete.fsproj";

  overrides = old: {
    passthru.fetch-deps = old.passthru.fetch-deps.overrideAttrs (fd: {
      text = lib.replaceStrings
        [ "projectFiles=(" ] [ "projectFiles=( ${projectFile}" ]
        fd.text;
    });
  };


  module =
    buildDotnetModule {
      inherit pname version;

      src = src + "/src";

      dotnet-sdk = dotnetCorePackages.sdk_8_0;
      dotnet-runtime = dotnetCorePackages.aspnetcore_8_0;

      # executables = [ "CSharpLanguageServer" ];

      # postInstall = ''
      #   makeWrapper "$out/lib/${pname}/CSharpLanguageServer" "$out/bin/${pname}" \
      #     --argv0 "${pname}" \
      #     --set-default DOTNET_ROOT "${dotnetCorePackages.aspnetcore_7_0}/"
      # '';

      meta = {
        description = "F# language server using Language Server Protocol";
        license = lib.licenses.asl20;
      };
    };

in
module.overrideAttrs overrides
