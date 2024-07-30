{ lib
, gawk
, jq
, writers
}:
let
  pname = "users-full";
  version = "0.1.0";
  script = writers.writeZshBin "${pname}" ''
    list_users() {
      local JQ_CMD
      local AWK_PROG

      read -r -d "" JQ_CMD <<-'JQ' || :
    .[]
      | .["dsAttrTypeStandard:UniqueID"]
      + .["dsAttrTypeStandard:RecordName"]
      + .["dsAttrTypeStandard:Password"]
      + .["dsAttrTypeStandard:PrimaryGroupID"]
      + .["dsAttrTypeStandard:RealName"]
      + .["dsAttrTypeStandard:NFSHomeDirectory"]
      + .["dsAttrTypeStandard:UserShell"]
      | @tsv
    JQ

      read -r -d "" AWK_PROG <<-'AWK' || :
    {
      print $2, $3, $1, $4, $5, $6, $7;
    }
    AWK

      dscl -plist . -readall /Users \
        | plutil -convert json -o - - \
        | ${lib.getExe jq} -cr "$JQ_CMD" \
        | sort -n \
        | ${lib.getExe gawk} -v FS='\t' -v OFS=':' "$AWK_PROG"
    }

    list_users
  '';
in
lib.standalone {
  inherit version script;
  meta = {
    platforms = lib.platforms.darwin;
  };
}
