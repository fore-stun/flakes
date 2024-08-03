{ lib
, fzf
, gawk
, udisks
, util-linux
, writers
}:
let
  pname = "mount-interactive";
  version = "0.1.0";
  script = writers.writeZshBin "${pname}" ''
    interactive_mount() {
      local DEVICE
      local MOUNTPOINT
      ${util-linux}/bin/lsblk -lnpb -o NAME,ID-LINK,MOUNTPOINT \
        | ${fzf}/bin/fzf --reverse --ansi \
          --preview-window=up,3 \
          --preview='print -l -- {1} {2} {3}' \
        | ${lib.getExe gawk} '{print $2, $3}' \
        | { read -r DEVICE MOUNTPOINT || : }

      if ! (( #DEVICE )); then
        print -l -- "No device selected" >&2
        return 0
      fi

      local CMD
      if (( #MOUNTPOINT )); then
        CMD="unmount"
      else
        CMD="mount"
      fi

      print -- "''${CMD}ing…" >&2

      ${udisks}/bin/udisksctl "''${CMD}" -b "/dev/disk/by-id/''${DEVICE}"
    }

    interactive_mount
  '';
in
lib.standalone {
  inherit version script;
  meta = {
    platforms = lib.platforms.linux;
  };
}
