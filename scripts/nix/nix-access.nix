{ lib
, gh
, writers
}:
let
  pname = "nix-access";
  version = "0.1.0";

  script = writers.writeZshBin "${pname}" ''
    if [[ -z "''${GITHUB_TOKEN:-}" ]]; then
      ${lib.getExe gh} auth status || ${lib.getExe gh} auth login
      typeset GITHUB_TOKEN
      ${lib.getExe gh} auth token \
        | read -r GITHUB_TOKEN
    fi

    NIX_CONFIG="access-tokens = github.com=''${GITHUB_TOKEN?}"
    export NIX_CONFIG

    "$@"
  '';
in
lib.standalone {
  inherit version script;
}
