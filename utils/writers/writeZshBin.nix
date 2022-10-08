{ writers, zsh }:

name: script:

writers.makeScriptWriter { interpreter = "${zsh}/bin/zsh"; } "/bin/${name}" (
  ''
    set -euo pipefail

    setopt EXTENDED_GLOB
    setopt LOCAL_OPTIONS
    setopt LOCAL_TRAPS
    setopt ERR_EXIT

    export LANG="''${LANG:-en_GB.UTF-8}"

  '' + script
)
