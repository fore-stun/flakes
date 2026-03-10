{ lib
, buildGoModule
, fetchFromGitHub
}:

let
  pname = "humble-cli";
  version = "0.22.0";
  owner = "smbl64";
  repo = pname;

  src = fetchFromGitHub {
    name = "${pname}-${version}-src";
    inherit owner repo;
    rev = "1afe4c3e84907238627e40eec2edb34969758dd8";
    hash = "sha256-PlLH14xg/6K9w2hoznOeYS5QmZRjKFJFSYBAUmbkLM8=";
  };

in

buildGoModule {
  inherit pname version src;
  vendorHash = "sha256-MX64vGynyC67u4bshXGWuU8mfQtlAzvChrfQJj8yDNg=";

  meta = with lib; {
    description = "The missing CLI for downloading your Humble Bundle purchases";
    homepage = "https://github.com/${owner}/${repo}";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "humble-cli";
  };
}
