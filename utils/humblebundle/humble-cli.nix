{ lib
, buildGoModule
, fetchFromGitHub
}:

let
  pname = "humble-cli";
  version = "0.21.3";
  owner = "smbl64";
  repo = pname;

  src = fetchFromGitHub {
    name = "${pname}-${version}-src";
    inherit owner repo;
    rev = "7b628eb33520d73f97a20aba05ccff73b2bb5238";
    hash = "sha256-d0jday50ChPRvs75l9sbsBDm/SP4FcztZw/toDcJAmM=";
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
