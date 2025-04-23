{ lib
, buildGoModule
, fetchFromGitHub
}:

let
  pname = "uuid";
  version = "0.5.1";
  owner = "timwmillard";
  repo = pname;
  src = fetchFromGitHub {
    inherit owner repo;
    name = "${pname}-${version}-src";
    rev = "71e85f72ce21e1890bf5efab62cfb16ed739f4d4";
    hash = "sha256-QvfszPvAl4nKDB9CshVMBY9MCOmORfJdR4zn0r0qH9M=";
  };
in
buildGoModule {
  inherit pname version src;

  vendorHash = "sha256-eHd1w8cnpnlkTiXQlQd/tPNGsMELpu3IoQRcS/YibXk=";

  meta = {
    description = "UUID generator";
    homepage = "https://github.com/${owner}/${repo}/";
    license = lib.licenses.mit;
    mainProgram = pname;
  };
}
