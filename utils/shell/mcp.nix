{ lib
, fetchFromGitHub
, rustPlatform
, openssl
, libiconv
, pkg-config
}:

let
  pname = "mcp";
  version = "v0.5.1";
  owner = "avelino";
  repo = "mcp";

  src = fetchFromGitHub {
    inherit owner repo;
    rev = "03c18fb7e41f56c33f2da6f26ce349b47ad60481";
    hash = "sha256-LKVx08rn6I/IgFtXKbMWMwlK/fwNvcWi3097LOPiP1E=";
  };
in
rustPlatform.buildRustPackage {
  inherit pname version src;

  cargoHash = lib.fakeHash;
  doCheck = false;

  nativeBuildInputs = [
    libiconv
    openssl
    pkg-config
  ];

  PKG_CONFIG_PATH = "${openssl.dev}/lib/pkgconfig";

  meta = {
    description = "CLI that turns MCP servers into terminal commands, single binary";
    homepage = "https://github.com/${owner}/${repo}";
    license = lib.licenses.mit;
    mainProgram = pname;
  };
}
