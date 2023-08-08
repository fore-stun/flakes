{ lib
, buildNpmPackage
, fetchFromGitHub
, nodejs_latest
}:

let
  pname = "prettier-plugin-svelte";
  version = "3.0.3";

  src = fetchFromGitHub {
    owner = "sveltejs";
    repo = pname;
    name = "${pname}-${version}-source";
    rev = "6fc0b64f3b906e247c40119b9d608f166d1a5939";
    hash = "sha256-/kHHnzkWtlFR/SVyr98sEvjIBp4oA1a+V3Q3pc9iKIw=";
  };

in
buildNpmPackage.override { nodejs = nodejs_latest; } {
  inherit pname version src;

  npmDepsHash = "sha256-r1AeUGs9LCKDyydppgVaJVtQf6w43nm4OfNqNNe4/p8=";

  meta = {
    description = "Svelte plugin for prettier";
    homepage = "https://github.com/sveltejs/prettier-plugin-svelte#readme";
    license = lib.licenses.mit;
  };
}
