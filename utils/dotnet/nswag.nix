{ lib
, buildDotnetModule
, dotnetCorePackages
, fetchNuGet
, fetchFromGitHub
, makeWrapper
}:

let
  pname = "nswag";
  version = "13.19.0";
  name = "${pname}-${version}";

  # src = fetchNuGet {
  #   pname = "NSwag.MSBuild";
  #   inherit version;
  #   sha256 = "sha256-WUnpopT+c1evNqqXtDGmKSoLRy2m00rM5x174VpQA0g=";
  # };

  src = fetchFromGitHub {
    name = "${name}-src";
    repo = "NSwag";
    owner = "RicoSuter";
    rev = "92b168a7c10371e0d163c7fbd7900a590aa13c1e";
    hash = "sha256-dYyd50qgNhq15QhDbnNHbVhFUYQ5dL2MoEJafGxzQnU=";
  };

  module =
    buildDotnetModule {
      inherit pname version src;

      nugetDeps = builtins.path {
        name = "${pname}-deps.nix";
        path = ./nswag-deps.nix;
      };

      dotnet-sdk = dotnetCorePackages.sdk_7_0;
      dotnet-runtime = dotnetCorePackages.aspnetcore_7_0;
      projectFile = "src/NSwag.sln";

      executables = [ "NSwag.MSBuild" ];

      # postInstall = ''
      #   makeWrapper "$out/lib/${pname}/CSharpLanguageServer" "$out/bin/${pname}" \
      #     --argv0 "${pname}" \
      #     --set-default DOTNET_ROOT "${dotnetCorePackages.aspnetcore_7_0}/"
      # '';

      meta = {
        description = "The Swagger/OpenAPI toolchain for .NET, ASP.NET Core and TypeScript.";
        license = lib.licenses.mit;
      };
    };

in
module
