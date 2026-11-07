{ lib, paths, ... }:
let
  inherit (lib) mkOption types;

  commonSystemdHardening = {
    LockPersonality = true;
    NoNewPrivileges = true;
    PrivateTmp = true;
    ProtectSystem = "strict";
    ProtectHome = true;
    ProtectKernelTunables = true;
    ProtectKernelModules = true;
    ProtectControlGroups = true;
    ProtectClock = true;
    ProtectHostname = true;
    RestrictSUIDSGID = true;
    RestrictRealtime = true;
    SystemCallArchitectures = "native";
    UMask = "0077";
  };

  dashboardHardwareModule = this: {
    options = {
      path = mkOption {
        type = types.path;
      };

      id = mkOption {
        type = types.str;
      };

      udevRule = mkOption {
        type = types.str;
        readOnly = true;
      };
    };

    config.udevRule = lib.concatStringsSep ", " [
      "SUBSYSTEM==\"input\""
      "KERNEL==\"event*\""
      "ENV{ID_PATH}==\"${this.config.id}\""
      "GROUP=\"dashboard\""
      "MODE=\"0660\""
    ];
  };
in
{
  modules.services.dashboard.nixos =
    this@{ pkgs, ... }:
    let
      cfg = this.config.services.dashboard;

      brightnessArgs = [
        "--input"
        (toString cfg.hardware.keyboard.path)
        "domain=volume"

        "--copy"
        "key:volumeup:1"
        "key:f13:0"
        "key:f13:1"
        "--copy"
        "key:volumeup:2"
        "key:f14:0"
        "key:f14:1"
        "--copy"
        "key:volumedown:1"
        "key:f15:0"
        "key:f15:1"
        "--copy"
        "key:volumedown:2"
        "key:f16:0"
        "key:f16:1"

        "--hook"
        "key:f13:1"
        "exec-shell=${dashboard}/bin/dashboard brightness 5%+"
        "--hook"
        "key:f14:1"
        "exec-shell=${dashboard}/bin/dashboard brightness 1%+"
        "--hook"
        "key:f15:1"
        "exec-shell=${dashboard}/bin/dashboard brightness 5%-"
        "--hook"
        "key:f16:1"
        "exec-shell=${dashboard}/bin/dashboard brightness 1%-"
      ];

      dashboard = pkgs.writeShellApplication {
        name = "dashboard";
        runtimeInputs = [
          pkgs.util-linux
          pkgs.coreutils
          pkgs.brightnessctl
        ];

        text = ''
          export TERM=linux

          msg="''${1:?error: no message}"
          shift

          case "$msg" in
            brightness)
              brightnessctl set "''${1:?error: no brightness value}"
              ;;

            screen)
              exec {tty}<>"/dev/${cfg.tty}" || exit 1
              cmd="''${1:-on}"
              case "$cmd" in
                on)
                  setterm --blank poke <&"$tty" >&"$tty"
                  ;;
                off)
                  setterm --blank force <&"$tty" >&"$tty"
                  ;;
                idle)
                  setterm --blank ${toString cfg.blankMinutes} <&"$tty" >&"$tty"
                  ;;
                *)
                  echo "error: unknown screen command '$cmd'"
                  exit 1
                  ;;
              esac
              ;;

            *)
              echo "error: unknown command '$msg'"
              exit 1
              ;;
          esac
        '';
      };

      backlightPermissions = pkgs.writeShellApplication {
        name = "dashboard-backlight-permissions";

        runtimeInputs = [ pkgs.coreutils ];

        text = ''
          chgrp dashboard "/sys/class/backlight/$1/brightness"
          chmod 0660 "/sys/class/backlight/$1/brightness"
        '';
      };

      evsieveArgs = lib.concatMap (line: lib.splitString " " line) [
        "--input ${toString cfg.hardware.gamepad.path} domain=pad grab"

        "--copy abs:hat0x:-1 key:leftalt:1@kb key:h:1@kb"
        "--copy abs:hat0x:-1..0~ key:leftalt:0@kb key:h:0@kb"
        "--copy abs:hat0x:1 key:leftalt:1@kb key:l:1@kb"
        "--copy abs:hat0x:1..~0 key:leftalt:0@kb key:l:0@kb"
        "--copy abs:hat0y:-1 key:leftalt:1@kb key:k:1@kb"
        "--copy abs:hat0y:-1..0~ key:leftalt:0@kb key:k:0@kb"
        "--copy abs:hat0y:1 key:leftalt:1@kb key:j:1@kb"
        "--copy abs:hat0y:1..~0 key:leftalt:0@kb key:j:0@kb"

        "--copy btn:south key:enter@kb"
        "--copy btn:east key:esc@kb"
        "--copy btn:north key:tab@kb"
        "--copy btn:west key:leftshift@kb key:tab@kb"

        "--copy btn:tl key:leftalt@kb key:1@kb"
        "--copy btn:tr key:leftalt@kb key:2@kb"

        "--output @kb name=dashboard-keybinds"
      ];

      execEvsieve = pkgs.writeShellApplication {
        name = "evsieve";

        runtimeInputs = [ pkgs.evsieve ];

        text = ''
          exec evsieve ${lib.escapeShellArgs evsieveArgs}
        '';
      };

      execBrightness = pkgs.writeShellApplication {
        name = "dashboard-brightness";

        runtimeInputs = [ pkgs.evsieve ];

        text = ''
          exec evsieve ${lib.escapeShellArgs brightnessArgs}
        '';
      };

      execZellij = pkgs.writeShellApplication {
        name = "zellij";

        runtimeInputs = [
          pkgs.btop
          pkgs.coreutils
          pkgs.fastfetch
          pkgs.zellij
        ];

        text = ''
          exec zellij --layout dashboard
        '';
      };
    in
    {
      options.services.dashboard = {
        tty = mkOption {
          type = types.str;
          default = "tty1";
        };

        blankMinutes = mkOption {
          type = types.ints.positive;
          default = 5;
        };

        hardware = {
          keyboard = mkOption {
            type = types.submodule dashboardHardwareModule;
          };

          gamepad = mkOption {
            type = types.submodule dashboardHardwareModule;
          };
        };
      };

      config = {
        environment.etc.dashboard.source = paths.dotfile "dashboard";

        hardware.uinput.enable = true;

        users.groups.dashboard = { };

        users.users.dashboard = {
          isSystemUser = true;
          group = "dashboard";
          extraGroups = [ "uinput" ];
          shell = pkgs.bash;
        };

        services.udev.extraRules = ''
          ${cfg.hardware.gamepad.udevRule}
          ${cfg.hardware.keyboard.udevRule}
          SUBSYSTEM=="backlight", RUN+="${backlightPermissions}/bin/dashboard-backlight-permissions %k"
        '';

        systemd.services.dashboard = {
          wantedBy = [ "multi-user.target" ];
          before = [ "getty.target" ];

          conflicts = [
            "autovt@${cfg.tty}.service"
            "getty@${cfg.tty}.service"
          ];

          serviceConfig = {
            User = "dashboard";
            Group = "dashboard";
            WorkingDirectory = "/var/empty";

            Environment = [
              "TERM=linux"
              "XDG_CONFIG_HOME=/etc/dashboard"
            ];

            ExecStartPre = "${pkgs.ncurses}/bin/clear";
            ExecStart = "${execZellij}/bin/zellij";

            Restart = "always";
            RestartSec = 2;
            SuccessExitStatus = [ 1 ];

            TTYPath = "/dev/${cfg.tty}";
            TTYReset = true;
            TTYVHangup = true;
            TTYVTDisallocate = true;

            StandardInput = "tty";
            StandardOutput = "tty";
          }
          // commonSystemdHardening;
        };

        systemd.services.dashboard-idle = {
          wantedBy = [ "multi-user.target" ];
          after = [ "dashboard.service" ];

          serviceConfig = {
            User = "dashboard";
            Group = "dashboard";
            WorkingDirectory = "/var/empty";

            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = "${dashboard}/bin/dashboard screen idle";
          }
          // commonSystemdHardening;
        };

        systemd.services.dashboard-keybinds = {
          wantedBy = [ "multi-user.target" ];
          after = [ "systemd-udev-settle.service" ];

          unitConfig.ConditionPathExists = [
            cfg.hardware.gamepad.path
          ];

          serviceConfig = {
            User = "dashboard";
            Group = "dashboard";
            WorkingDirectory = "/var/empty";

            ExecStart = "${execEvsieve}/bin/evsieve";
            Restart = "always";
            RestartSec = 2;
          }
          // commonSystemdHardening;
        };

        systemd.services.dashboard-brightness = {
          wantedBy = [ "multi-user.target" ];
          after = [ "systemd-udev-settle.service" ];

          unitConfig.ConditionPathExists = [
            cfg.hardware.keyboard.path
          ];

          serviceConfig = {
            User = "dashboard";
            Group = "dashboard";
            WorkingDirectory = "/var/empty";

            ExecStart = "${execBrightness}/bin/dashboard-brightness";
            Restart = "always";
            RestartSec = 2;
          }
          // (removeAttrs commonSystemdHardening [ "ProtectKernelTunables" ]);
        };

        # purely for convenience
        environment.systemPackages = [
          dashboard
          pkgs.evsieve
          pkgs.brightnessctl
        ];
      };
    };
}
