{ lib
, coreutils
, findutils
, fzf
, gawk
, gh
, jujutsu
, moreutils
, ripgrep
, writers
}:
let
  pname = "jj-scripts";
  version = "0.1.0";
  prefixStringLines = prefix: str:
    lib.concatMapStringsSep "\n" (line: prefix + line) (lib.splitString "\n" str);

  indent = prefixStringLines "  ";

  functions = {
    track-bookmarks = indent ''
      ${lib.getExe jujutsu} bookmark list --ignore-working-copy -a \
        | ${lib.getExe gawk} '$1 ~ /^[^ ]+@origin:$/ { $1 = substr($1,0,length($1) - 1); print $1 }' \
        | ${lib.getExe fzf} --reverse --ansi --multi --preview="${lib.getExe jujutsu} log -r ::{} --ignore-working-copy --color=always" \
        | ${moreutils}/bin/ifne ${findutils}/bin/xargs -I {} ${lib.getExe jujutsu} bookmark track {}
    '';

    delete-bookmarks = indent ''
      ${lib.getExe jujutsu} bookmark list --ignore-working-copy 2>/dev/null  \
        | ${lib.getExe gawk} '$0 ~ /^[^ ]/ && $1 ~ /:$/ { $1 = substr($1,0,length($1) - 1); print $1 }' \
        | ${lib.getExe fzf} --reverse --ansi --multi --preview="${lib.getExe jujutsu} log -r ::{} --ignore-working-copy --color=always" \
        | ${moreutils}/bin/ifne ${findutils}/bin/xargs -I {} ${lib.getExe jujutsu} bookmark delete {}
    '';

    backout-show = ''
        local OP_LOG_ID_TEMPLATE
        read -r -d "" OP_LOG_ID_TEMPLATE <<-'JJT' || :
      self.id().short() ++ "\n"
      JJT

        ${lib.getExe jujutsu} backout "$@" \
          && {
            ${lib.getExe jujutsu} op log -n1 --no-pager --no-graph --ignore-working-copy -T "''${OP_LOG_ID_TEMPLATE}" \
              | ${findutils}/bin/xargs ${lib.getExe jujutsu} op show --no-graph --ignore-working-copy --color=always \
              | ${lib.getExe ripgrep} --color=never 'Back out'
          }
    '';

    op-restore = ''
        local OP_RESTORE_TEMPLATE
        read -r -d "" OP_RESTORE_TEMPLATE <<-'JJT' || :
      self.id().short() ++ "\n"
      JJT
        ${lib.getExe jujutsu} op log -T "''${OP_RESTORE_TEMPLATE}" --no-graph --ignore-working-copy 2>/dev/null \
          | ${lib.getExe fzf} --reverse --ansi --multi --preview-window="up" \
            --preview="${lib.getExe jujutsu} op show {} --ignore-working-copy --color=always" \
          | ${moreutils}/bin/ifne ${findutils}/bin/xargs -I {} ${lib.getExe jujutsu} op restore {}
    '';

    evolog-check = ''
        local REVSET="''${1?Revset}"
        local EVOLOG_TAB
        read -r -d "" EVOLOG_TAB <<-'JJT' || :
      separate("\t"
        , self.change_id().short()
        , self.commit_id().short()
        , if(self.conflict(), "conflict", "")
        ) ++ "\n"
      JJT

        ${lib.getExe jujutsu} evolog -T "''${EVOLOG_TAB}" -r "''${REVSET}" --no-graph --ignore-working-copy 2>/dev/null \
          | ${lib.getExe fzf} --reverse --ansi --multi --preview-window="up" \
            --preview="${lib.getExe jujutsu} show -r {2} --color=always --ignore-working-copy" \
          | ${moreutils}/bin/ifne ${coreutils}/bin/cut -f2 \
          | ${moreutils}/bin/ifne ${findutils}/bin/xargs  -I {} ${lib.getExe jujutsu} show -r {} --ignore-working-copy
    '';

    noblame = ''
        zparseopts -D -E -F -- \
          i=OPT_interactive

        local HEADLINE="''${1?Commit headline}"

        if [[ "$#HEADLINE" -ge 41 ]]; then
          print -- "Commit headline too long" >&2
          return 41
        fi

        local IGNORE_BLAME_TEMPLATE
        local BP_NOBLAME
        local BP_IGNOREHEAD

        read -r -d "" IGNORE_BLAME_TEMPLATE <<-'JJT' || :
      concat( "# " , description.first_line() , "\n"
        , "# " , change_id , "\n"
        , commit_id , "\n"
        )
      JJT

        read -r -d "" BP_NOBLAME <<- 'NOBLAME' || :
      If this commit appears in your `git blame`, you need to run the
      following to configure the `.git-blame-ignore-revs` file.

      ```
      git config blame.ignoreRevsFile .git-blame-ignore-revs
      ```

      If you have done that, then please replace the erroneous commit in that
      file with the hash of this commit.
      NOBLAME

        read -r -d "" BP_IGNOREHEAD <<- 'IGNOREHEAD' || :
      Run the following to ignore the HEAD commit

      ```
      git show --no-patch --format="%n# %s%n%H" >> .git-blame-ignore-revs
      ```
      IGNOREHEAD

        ${lib.getExe jujutsu} desc --stdin <<- NOBLAME
      ''${HEADLINE}

      ''${BP_NOBLAME}
      NOBLAME

        if (( #OPT_interactive )); then
          ${lib.getExe jujutsu} split
          ${lib.getExe jujutsu} new -r @-
        else
          ${lib.getExe jujutsu} new
        fi

        print -l -- "" >> .git-blame-ignore-revs
        ${lib.getExe jujutsu} log --no-graph --no-pager \
          --template "''${IGNORE_BLAME_TEMPLATE}" \
          -r @- >> .git-blame-ignore-revs

        ${lib.getExe jujutsu} desc --stdin <<- IGNOREHEAD
      Ignore ‘''${HEADLINE}’

      ''${BP_IGNOREHEAD}
      IGNOREHEAD

        ${lib.getExe jujutsu} new
    '';

    gh-pr-merge = indent ''
      local TIP
      ${lib.getExe jujutsu} bookmark list -r "heads(::@- & bookmarks())" -T "name" \
        | { read -r TIP || : }

      ${lib.getExe gh} pr merge -m "''${TIP}" \
        && ${lib.getExe jujutsu} bookmark delete "''${TIP}" \
        && ${lib.getExe jujutsu} git fetch \
        && ${lib.getExe jujutsu} rebase -r "at_operation(@-,trunk()):: ~ ::trunk()" -d "trunk()"  \
        && ${lib.getExe jujutsu} git push --tracked \
        && ${lib.getExe jujutsu} new "trunk()"
    '';

    gh-pr-create = indent ''
      local CURRENT_BOOKMARK
      ${lib.getExe jujutsu} bookmark list -r "@-" -T "name" \
        | { read -r CURRENT_BOOKMARK || : }

      if (( #CURRENT_BOOKMARK )); then
        ${lib.getExe jujutsu} git push -b "''${CURRENT_BOOKMARK}"
      else
        ${lib.getExe jujutsu} git push -c "@-"
        ${lib.getExe jujutsu} bookmark list -r "@-" -T "name" \
          | { read -r CURRENT_BOOKMARK || : }
      fi

      ${lib.getExe gh} pr create -H "''${CURRENT_BOOKMARK}" "$@"
    '';

    gh-pr-view = indent ''
      local TIP
      ${lib.getExe jujutsu} bookmark list -r "heads(::@- & bookmarks())" -T "name" \
        | { read -r TIP || : }

      ${lib.getExe gh} pr view --web "''${TIP}"
    '';

    merge-trunk = indent ''
      local BRANCH="''${1?Branch name}"
      ${lib.getExe jujutsu} bookmark delete "@-" 2>/dev/null || :
      ${lib.getExe jujutsu} new "trunk()" "@-" -m "Merge branch ''\'''${BRANCH}'" \
        && ${lib.getExe jujutsu} new \
        && ${lib.getExe jujutsu} bookmark move --from "heads(::@- & bookmarks())" --to "@-"
    '';
  };

  wrapFunctions =
    let
      f = name: inner:
        let fname = "_jj_${lib.replaceStrings ["-"] ["_"] name}";
        in ''
          renamed[${name}]="${fname}"
          ${fname}() {
          ${inner}
          }
        '';
    in
    lib.flip lib.pipe [
      (lib.mapAttrsToList f)
      (lib.concatStringsSep "\n\n")
    ];

  script = writers.writeZshBin "${pname}" ''
    typeset -A renamed

    ${wrapFunctions functions}
    function help() {
      echo "${pname} functions:"
      echo "> ''${(@)subcommands}"
    }

    local -a subcommands
    subcommands=(''${(k)functions:#_*} ''${(k)renamed})

    if [ $# -ge 1 ] && grep -q "$1" <<< "''${(@)subcommands}"
    then
      "''${renamed[(e)$1]:-$1}" "$@[2,-1]"
      exit 0
    else
      echo "Not a ${pname} sub-command: $1" >&2
      exit 2
    fi
  '';


in
lib.fix (this:
let
  mkAlias = n: _: [ "util" "exec" "--" "${lib.getExe this}" "${n}" ];
in
lib.standalone {
  inherit version script;
  passthru = {
    aliases = lib.mapAttrs mkAlias functions;
  };
})
