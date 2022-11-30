{ lib
, coreutils
, writers
}:
let
  pname = "twoway";
  version = "0.1.0";
  help = ''
    Sync two files, using rsyunc. Extremely hacky. Super lightweight.

    Usage: ${pname} <Local file> <Remote file>

    This compares files by their hash, and if different it writes the file with the
    newer timestamp over the one with the older timestamp (using rsync).

    Options:
    -h --help     Show this help text
    -n --dry-run  Don't actually sync the files
  '';

  script = writers.writeZshBin "${pname}" ''
    zparseopts -D -E -F -- \
      h=OPT_help -help=OPT_help \
      n=OPT_dry_run -dry-run=OPT_dry_run

    if (( #OPT_help )); then
      local -a help_lines=(
        ${lib.concatMapStringsSep "\n    " lib.escapeShellArg (lib.splitString "\n" help)}
      )
      print -l -- "''${(@)help_lines}" >&2
      return 0
    fi

    local LOCAL_FILE="''${1?Local file}"
    local REMOTE_FILE="''${2?Remote file}"

    local LOCAL_FILE_EXISTS
    local REMOTE_FILE_EXISTS
    LOCAL_FILE_EXISTS="$([[ -f "$LOCAL_FILE" ]] && print 1 || print 0)"
    REMOTE_FILE_EXISTS="$([[ -f "$REMOTE_FILE" ]] && print 1 || print 0)"

    if ! (( LOCAL_FILE_EXISTS + REMOTE_FILE_EXISTS )); then
      print -- "No files to sync" >&2
      return 2
    fi

    getSha() {
      local LABEL="''${1?File label}"
      local FILE="''${2?File}"
      local EXISTS="''${3?File exists?}"

      if (( EXISTS )); then
        ${coreutils}/bin/sha256sum "$FILE" \
          | cut -d" " -f1
      else
        read -rsq "CONFIRM_0?Create $LABEL file $FILE? (y/N) " || :
        [[ "$CONFIRM_0" = "y" ]] || { print -- "\nExiting" >&2 ; return 4 }
      fi
    }

    local LOCAL_SHA
    getSha local "$LOCAL_FILE" "$LOCAL_FILE_EXISTS" \
      | { read -r LOCAL_SHA || : }

    local STATUS="$?"
    (( STATUS )) && return "$STATUS"

    local REMOTE_SHA
    getSha remote "$REMOTE_FILE" "$REMOTE_FILE_EXISTS" \
      | { read -r REMOTE_SHA || : }

    STATUS="$?"
    (( STATUS )) && return "$STATUS"

    if [[ "$LOCAL_SHA" = "$REMOTE_SHA" ]]; then
      print -- "Hashes the same" >&2
      return 0
    fi

    local LOCAL
    if (( LOCAL_FILE_EXISTS )); then
      ${coreutils}/bin/stat -c"%Z" "$LOCAL_FILE" | read -r LOCAL
    fi

    local REMOTE
    if (( REMOTE_FILE_EXISTS )); then
      ${coreutils}/bin/stat -c"%Z" "$REMOTE_FILE" | read -r REMOTE
    fi

    if ! (( LOCAL - REMOTE )); then
      print -- "Timestamps the same" >&2
      return 0
    fi

    local -a cmds=(rsync -ah --progress)
    local OUTCOME_MESSAGE

    if [[ "$LOCAL" -gt "$REMOTE" ]]; then
      # local newer
      OUTCOME_MESSAGE="back up local file"
      cmds+=("$LOCAL_FILE" "$REMOTE_FILE")
    else
      # remote newer
      OUTCOME_MESSAGE="restore from local file"
      cmds+=("$REMOTE_FILE" "$LOCAL_FILE")
    fi

    if (( #OPT_dry_run )); then
      print -- "\nWould $OUTCOME_MESSAGE" >&2
      return 0
    fi

    print -- "\nWill $OUTCOME_MESSAGE" >&2

    "''${(@)cmds}" >&2
  '';
in
lib.standalone { inherit version script; }
