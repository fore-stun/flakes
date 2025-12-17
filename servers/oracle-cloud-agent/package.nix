{ lib
, fetchurl
, makeBinaryWrapper
, squashfsTools
, stdenv
}:

let
  pname = "oracle-cloud-agent";

  inherit (stdenv.hostPlatform) system;

  input = lib.findFirst
    (x: x.system == system)
    (throw "No matching source for ${pname} on ${system}")
    [
      {
        system = "x86_64-linux";
        version = "1.24.0-9727";
        url = "https://api.snapcraft.io/api/v1/snaps/download/ltx4XjES2e2ujitNIuO5GxPYDM6lp6ry_40.snap";
        hash = "sha256-JYUX1QTsUEDb2uGkZVrXFO1wo8KHjtIiin4H3mckxdM=";
        patches = [ ./agent.yml.x86_64.patch ];
      }
      {
        system = "aarch64-linux";
        url =
          "https://api.snapcraft.io/api/v1/snaps/download/ltx4XjES2e2ujitNIuO5GxPYDM6lp6ry_41.snap";
        version = "1.24.0-1";
        hash = "sha256-ePpDb3ZpMWzxbBlVpCh2KFtsEWGimhD573s+UZLBmS8=";
        patches = [ ./agent.yml.aarch64.patch ];
      }
    ];

  src = fetchurl {
    name = "${pname}-${input.version}-src";
    inherit (input) url hash;
    downloadToTemp = true;
    recursiveHash = true;
    postFetch = ''
      ${squashfsTools}/bin/unsquashfs "$downloadedFile"
      mkdir -p "$out"
      cp -Rv squashfs-root/* "$out"
    '';
  };

  meta = {
    description = "Agent for oracle cloud instances";
    homepage = "https://docs.oracle.com/en-us/iaas/Content/Compute/Tasks/manage-plugins.htm";
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    license = lib.licenses.upl;
    mainProgram = "oci";
  };

  PLUGINS = [
    "gomon"
    "oci-managementagent"
    # "oci-jms"
    "oci-vulnerabilityscan"
    "unifiedmonitoring"
  ];

  buildPhase = ''
    runHook preBuild

    substituteAllInPlace agent.yml

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin" "$out/etc" "$plugin/bin" "$plugin/etc"

    install -m750 -T agent "$out/bin/.agent"
    install -m640 agent.yml "$out/etc/"

    makeWrapper "$out/bin/.agent" "$out/bin/oracle-cloud-agent" \
      --inherit-argv0 \
      --add-flags "-agent-config $out/etc/agent.yml"

    install -m750 -T plugins/bastions "$plugin/bin/bastions"
    install -m640 -T plugins/bastions-config/config.yml "$plugin/etc/bastions.yml"

    wrapProgram "$plugin/bin/bastions" \
      --add-flags "-agent-config $plugin/etc/bastions.yml" \

    for p in ''${PLUGINS[@]}; do
      local PLUGIN_DIR="plugins/$p"
      local PLUGIN_OUT="$plugin/bin/''${p}"
      local CONFIG_OUT="$plugin/etc/''${p}.yml"

      if [ ! -d $PLUGIN_DIR ]; then
        continue
      fi

      local -a wrap_args=("$PLUGIN_OUT")

      install -m750 -T "$PLUGIN_DIR/$p" "$PLUGIN_OUT"

      if [ $p != oci-vulnerabilityscan ]; then
        install -m640 -T "$PLUGIN_DIR/config/config.yml" "$CONFIG_OUT"
        wrap_args+=(
          --add-flags "-agent-config $CONFIG_OUT"
        )
      fi

      wrapProgram "''${wrap_args[@]}"
    done

    runHook postInstall
  '';

in
stdenv.mkDerivation {
  inherit pname meta src;
  inherit (input) version patches;

  inherit buildPhase installPhase;
  inherit PLUGINS;

  outputs = [ "out" "plugin" ];

  dontPatchELF = true;

  nativeBuildInputs = [ makeBinaryWrapper ];
}
