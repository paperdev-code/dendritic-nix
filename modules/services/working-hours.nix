{ lib, ... }:
let
  inherit (lib) mkIf mkOption types;

  workingUnitName = "working-hours";
  closingUnitName = "closing-hours";

  serviceModule = this: {
    options.working-hours = mkOption {
      type = types.bool;
      default = false;
    };

    config = mkIf this.config.working-hours {
      wantedBy = [ "${workingUnitName}.target" ];
      conflicts = [ "${closingUnitName}.target" ];
    };
  };
in
{
  modules.working-hours.nixos =
    this:
    let
      cfg = this.config.services.working-hours;
    in
    {
      options.services.working-hours = {
        opening = mkOption {
          type = types.str;
          default = "*-*-* 09:00:00";
        };

        closing = mkOption {
          type = types.str;
          default = "*-*-* 01:00:00";
        };
      };

      options.systemd.services = mkOption {
        type = with types; attrsOf (submodule serviceModule);
      };

      config = {
        systemd.targets = {
          ${workingUnitName} = {
            conflicts = [ "${closingUnitName}.target" ];
          };

          ${closingUnitName} = {
            conflicts = [ "${workingUnitName}.target" ];
          };
        };

        systemd.timers = {
          ${workingUnitName} = {
            wantedBy = [ "timers.target" ];
            timerConfig = {
              OnCalendar = cfg.opening;
              Unit = "${workingUnitName}.target";
            };
          };

          ${closingUnitName} = {
            wantedBy = [ "timers.target" ];
            timerConfig = {
              OnCalendar = cfg.closing;
              Unit = "${closingUnitName}.target";
            };
          };
        };
      };
    };
}
