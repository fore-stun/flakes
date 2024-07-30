{ lib
, dhall-json
, writers
}:
let
  pname = "plistview";
  version = "0.1.0";

  script = writers.writeZshBin "${pname}" ''
    zparseopts -D -E -F \
      -help=help h=help

    HELP="Use: ''${0:t} <PLIST_FILE>"
    [ ''${#help[@]} -gt 0 ] && echo "$HELP" >&2 && exit 0

    function plistview () {
      PLIST_FILE="''${1?Supply a plist file}"
      plutil -convert json -o - "$PLIST_FILE" | ${dhall-json}/bin/json-to-dhall
    }

    plistview "$@"

  '';
in
lib.standalone {
  inherit version script;
  meta = {
    platforms = lib.platforms.darwin;
  };
}
