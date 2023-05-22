{ lib
, fetchFromGitHub
, deno2nix
}:

let
  pname = "deno_bindgen";
  version = "0.8.0";
  owner = "denoland";
  repo = pname;

  src = fetchFromGitHub {
    inherit owner repo;
    rev = "12c8748e8ce032f9cccaea0d1120b634f96a5d29";
    hash = "sha256-YTs/nkyUpifF40qBvN1xfyHacoPr8RtnngGQpg1O5kg=";
  };
in
deno2nix.mkExecutable {
  inherit pname version src;

  entrypoint = "cli.ts";

  meta = {
    description = "Simplified glue code generation for Deno FFI libraries written in Rust.";
    homepage = "https://github.com/${owner}/${repo}";
    license = lib.licenses.mit;
  };
}
