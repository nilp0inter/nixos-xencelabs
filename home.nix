xencelabs:
{ pkgs, config, lib, ... }:
let
  cfg = config.programs.xencelabs;
in
with lib; {
  options = {
    programs.xencelabs = {
      enable = mkEnableOption "XenceLabs";
    };
  };
  config = mkIf cfg.enable {
    home.packages = [ xencelabs ];
    systemd.user.services.xencelabs = {
      Unit = {
        Description = "XenceLabs Driver";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Install = { WantedBy = [ "graphical-session.target" ]; };

      Service = {
        Environment = "PATH=${config.home.profileDirectory}/bin:${pkgs.coreutils}/bin:${pkgs.gawk}/bin";
        ExecStart = "${xencelabs}/bin/xencelabs";
        Restart = "on-abort";
        RestartSec = 3;
      };
    };
  };
}
