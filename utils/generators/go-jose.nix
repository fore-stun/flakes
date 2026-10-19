{ lib
, buildGoModule
, fetchFromGitHub
}:

let
  pname = "go-jose";
  version = "4.1.6";
  owner = "go-jose";
  repo = pname;
  src = fetchFromGitHub {
    inherit owner repo;
    name = "${pname}-${version}-src";
    tag = "v${version}";
    hash = "sha256-nLARPCcOLjUFYFkmSnTcYfebdk77LoBK7MZHjFsk9fI=";
  };
in
buildGoModule {
  inherit pname version src;

  # v4.1.6 has no module dependencies beyond the standard library.
  vendorHash = null;

  # Build only the CLI in jose-util/, not the library packages.
  subPackages = [ "jose-util" ];

  env.CGO_ENABLED = "0";

  ldflags = [
    "-s"
    "-w"
  ];

  doCheck = false;

  preCheck = ''
    unset subPackages
  '';

  postCheck = ''
    cd "$sourceRoot"
    go test ./...
  '';

  meta = {
    description = "An implementation of JOSE standards (JWE, JWS, JWT) in Go Resources";
    homepage = "https://github.com/${owner}/${repo}/";
    license = lib.licenses.asl20;
    mainProgram = "jose-util";
  };
}
