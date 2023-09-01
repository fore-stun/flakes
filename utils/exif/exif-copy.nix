{ lib
, dhall-json
, exiftool
, jq
, moreutils
, writers
}:
let
  pname = "exif-copy";
  version = "0.1.0";
  script = writers.writeZshBin "${pname}" ''
    ${lib.getExe exiftool} -j "''${1?Input file}" \
      | ${lib.getExe jq} 'map(.SourceFile = "*")' \
      | ${dhall-json}/bin/json-to-dhall \
      | ${moreutils}/bin/vipe \
      | ${moreutils}/bin/ifne ${dhall-json}/bin/dhall-to-json \
      | ${moreutils}/bin/ifne ${lib.getExe exiftool} -j=- "''${2?Input file}"
  '';
in
lib.standalone { inherit version script; }
