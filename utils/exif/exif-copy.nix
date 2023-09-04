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

    zparseopts -D -E -F -- \
      -move-to:=ARG_move m:=ARG_move \
      -filter:=ARG_filter F:=ARG_filter \
      -filter-file:=ARG_filter_file f:=ARG_filter_file \
      -no-edit=OPT_no_edit E=OPT_no_edit

    local FILTER
    if (( $#ARG_filter_file )); then
      if [[ ''${ARG_filter_file[2]?} = '-' ]]; then
        { read -r -d"" -u0 FILTER <&0 || : }
      else
        { read -r -d"" FILTER < ''${ARG_filter_file[2]?} || : }
      fi
    elif (( $#ARG_filter )); then
      FILTER="''${ARG_filter[2]:-}"
    fi

    local EDIT=1
    if (( #OPT_no_edit )); then
      EDIT=0
    fi

    local OUTPUT
    if (( $#ARG_move )); then
      OUTPUT=''${ARG_move[2]?}
    fi

    pre_filter() {
      if (( #FILTER )); then
        ${lib.getExe jq} "map(''${FILTER})"
      else
        cat
      fi
    }

    edit_dhall() {
      if (( EDIT )); then
        ${moreutils}/bin/ifne ${dhall-json}/bin/json-to-dhall \
          | ${moreutils}/bin/vipe \
          | ${moreutils}/bin/ifne ${dhall-json}/bin/dhall-to-json
      else
        cat
      fi
    }

    ${lib.getExe exiftool} -j "''${1?Original file}" \
      | pre_filter \
      | edit_dhall \
      | ${lib.getExe jq} 'map(. + {SourceFile: "*"})' \
      | ${moreutils}/bin/ifne ${lib.getExe exiftool} -j=- "''${2?Input file}"

    if [[ -f "$OUTPUT" ]]; then
      exit 3
    elif (( #OUTPUT )); then
      mv -v "$2" "$OUTPUT"
    fi
  '';
in
lib.standalone { inherit version script; }
