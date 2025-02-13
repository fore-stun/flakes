{ lib
, findutils
, fzf
, gawk
, jujutsu
, moreutils
, writers
}:
let
  pname = "jj-track";
  version = "0.1.0";
  script = writers.writeZshBin "${pname}" ''
    jj_track() {
      ${lib.exe jujutsu} bookmark list -a \
        | ${lib.exe gawk} '$1 ~ /^[^ ]+@origin:$/ { $1 = substr($1,0,length($1) - 1); print $1 }' \
        | ${lib.exe fzf} --reverse --ansi --multi --preview="jj log -r ::{} --color=always" \
        | ${moreutils}/bin/ifne ${findutils}/bin/xargs -I {} ${lib.exe jujutsu} bookmark track {}
    }

  '';
in
lib.standalone {
  inherit version script;
  meta = {
    platforms = lib.platforms.linux;
  };
}
