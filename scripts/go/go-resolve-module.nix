{ lib
, writers
}:
let
  pname = "go-resolve-module";
  version = "0.1.0";

  script = writers.writeZshBin "${pname}" ''
  '';

in
lib.standalone {
  inherit version script;
}
