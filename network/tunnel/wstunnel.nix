{ lib
, crane
, darwin
, fetchFromGitHub
, hostPlatform
, libiconv
, system
}:

let
  pname = "wstunnel";
  version = "9.2.4";
  owner = "erebe";
  repo = pname;

  clib = crane.lib.${system};

  src = fetchFromGitHub {
    inherit owner repo;
    rev = "832e253b3cc8ed0c1215d18526911d106319d329";
    hash = "sha256-BWJgw7YNdRMbNwb+s8NYc9QNUACD3QQbISB0h8eHJLg=";
  };
in
clib.buildPackage {
  inherit pname version src;

  nativeBuildInputs = [
    libiconv
  ] ++ lib.optionals hostPlatform.isDarwin [
    darwin.apple_sdk.frameworks.CoreServices
    darwin.apple_sdk.frameworks.Security
  ];

  doCheck = false;

  meta = {
    description = "Tunnel all your traffic over Websocket or HTTP2 - Bypass firewalls/DPI - Static binary available Topics";
    homepage = "https://github.com/${owner}/${repo}";
    license = lib.licenses.bsd3;
    mainProgram = pname;
  };
}
