{ lib
, eza
, fzf
, gawk
, home-manager
, writers
}:
let
  pname = "home-manager-specialisation";
  version = "0.1.0";

  script = writers.writeZshBin "${pname}" ''
    switch_generation() {
      local -a generations

      local LOCAL_GENERATION
      readlink -f "''${HOME?Home directory}/.local/state/home-manager/gcroots/current-generation/" \
        | { read -r -d "" LOCAL_GENERATION || : }

      if [[ -d "''${LOCAL_GENERATION}" ]]; then
        generations+=("''${LOCAL_GENERATION}")
      fi

      local LOCAL_ROOT
      readlink -f "''${HOME?Home directory}/.local/state/home-manager/gcroots/current-home/" \
        | { read -r -d "" LOCAL_ROOT || : }

      if [[ -d "''${LOCAL_ROOT}" ]]; then
        generations+=("''${LOCAL_ROOT}")
      fi

      local GENERATIONS
      ${lib.getExe home-manager} generations \
        | ${lib.getExe gawk} -v FS='( : id | -> )' -v OFS="\t" '{$1=$1; print $3}' \
        | { read -r -d "" GENERATIONS || : }

      generations+=("''${(f)GENERATIONS}")

      if ! (( $#generations )); then
        print -l -- "No generation found." >&2
        return 3
      fi

      local MAIN_GENERATION
      for g in "''${(@)generations}"; do
        if [[ -d "$g/specialisation" ]]; then
          MAIN_GENERATION="$g"
          break
        fi
      done

      if ! (( #MAIN_GENERATION )); then
        print -l -- "No specialisation found." >&2
        return 4
      fi

      local SPECIALISATION
      ${lib.getExe eza} "$MAIN_GENERATION/specialisation" \
        | ${lib.getExe gawk} -F " -> " -v OFS="\t" -v GENERATION="$MAIN_GENERATION" \
          'BEGIN {print "default", GENERATION} {print $1, $2}' \
        | ${fzf}/bin/fzf-tmux -p 80%,80% --reverse --ansi --multi \
          --delimiter '\t' --with-nth '1' \
          --preview-window="bottom,50%,wrap" \
          --preview="echo {2}" \
          --bind 'ctrl-f:preview-page-down,ctrl-b:preview-page-up' \
        | cut -f2 \
        | read -r SPECIALISATION

      if ! (( #SPECIALISATION )); then
        print -l -- "No specialisation selected." >&2
        return 5
      fi

      read -qs "REPLY?Activate $SPECIALISATION? (y/N)"

      if [[ "$REPLY" != "y" ]]; then
        print -l -- "Not activating specialisation." >&2
        return 0
      fi

      "$SPECIALISATION/activate" --driver-version 1
    }

    switch_generation
  '';
in
lib.standalone {
  inherit version script;
}
