{ lib
, buildNpmPackage
, fetchFromGitHub
, python3
}:

let
  pname = "storage-api";
  version = "0.37.9";
  src = fetchFromGitHub {
    owner = "supabase";
    repo = pname;
    rev = "1794d04ab0e7259d9058293e257f442015252ec3";
    hash = "sha256-xIeIx2VrprbTfR+N6V1zEi2ex+mXspTw8UqLW3wD+YY=";
  };
in
buildNpmPackage {
  inherit pname version src;

  npmDepsHash = "sha256-zbxKzSoOYwchi06bgRSDAnxbb15q1qWmu0bAZDnhbzU=";

  nativeBuildInputs = [ python3 ];

  patches = [
    (builtins.path {
      name = "${pname}.patch";
      path = ./storage-api.patch;
    })
  ];

  meta = {
    description = "S3 compatible object storage service that stores metadata in Postgres";
    homepage = "https://supabase.com/docs/guides/storage";
    license = lib.licenses.asl20;
    mainProgram = "supa-storage";
  };
}
