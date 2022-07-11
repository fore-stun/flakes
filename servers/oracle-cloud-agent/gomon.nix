{ pkgs }:
{ lib, config, ... }:

let
  cfg = config.services.gomon;
  inherit (lib) types;

in
{
  options.services.gomon = {
    enable = lib.mkEnableOption "OCI monitoring with gomon";

    package = lib.mkOption {
      type = types.package;
      default = pkgs.oracle-cloud-agent.plugin;
      defaultText = lib.literalExpression "pkgs.oracle-cloud-agent.plugin";
      description = "The package to use for gomon";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    systemd.services.gomon = {
      description = "OCI monitoring with gomon";

      after = [ "network-post.target" ];
      wants = [ "network-post.target" ];
      wantedBy = [ "multi-user.target" ];

      stopIfChanged = false;

      script = ''
        ${cfg.package}/bin/gomon -cli -log-file /dev/stdout
      '';

      serviceConfig = {
        Restart = "on-failure";
        RestartSec = "3";
        DynamicUser = true;
        CapabilityBoundingSet = "";
      };

    };
  };
}
