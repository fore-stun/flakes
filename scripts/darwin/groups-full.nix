{ lib
, gawk
, jq
, writers
}:
let
  pname = "groups-full";
  version = "0.1.0";

  script = writers.writeZshBin "${pname}" ''
    list_groups() {
      local JQ_CMD
      local AWK_PROG

      read -r -d "" JQ_CMD <<-'JQ' || :
    .[]
      | .["dsAttrTypeStandard:PrimaryGroupID"]
      + .["dsAttrTypeStandard:Password"]
      + .["dsAttrTypeStandard:RecordName"]
      + .["dsAttrTypeStandard:GroupMembership"]
      | @tsv
    JQ

      read -r -d "" AWK_PROG <<-'AWK' || :
    {
      remainder = $4;
      for (i=5; i<=NF; i++) {
        remainder = remainder "," $i;
      }
      print $3, $2, $1, remainder;
    }
    AWK

      dscl -plist . -readall /Groups\
        | plutil -convert json -o - - \
        | ${lib.getExe jq} -cr "$JQ_CMD" \
        | sort -n \
        | ${lib.getExe gawk} -v FS='\t' -v OFS=':' "$AWK_PROG"
    }

    list_groups
  '';
in
lib.standalone {
  inherit version script;
  meta = {
    platforms = lib.platforms.darwin;
  };
}
