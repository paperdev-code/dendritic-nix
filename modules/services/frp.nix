{
  lib,
  ...
}:
let
  inherit (lib)
    escapeShellArg
    mkDefault
    mkForce
    mkOption
    types
    ;

  tlsModule = {
    options = {
      caFile = mkOption {
        type = types.path;
      };

      certFile = mkOption {
        type = types.path;
      };

      keyFile = mkOption {
        type = types.path;
      };
    };
  };

in
{
  modules.services.frp.client.nixos =
    this@{ pkgs, ... }:
    let
      tomlFormat = pkgs.formats.toml { };

      cfg = this.config.services.frp.client;
      includesDir = "${cfg.stateDir}/frpc.d";

      proxyTemplate = pkgs.writeText "frpc-proxies.toml" ''
        # add proxies here
        # [reference](https://gofrp.org/en/docs/features/tcp-udp/)
      '';
    in
    {
      options.services.frp.client = {
        tls = mkOption {
          type = types.submodule tlsModule;
        };

        serverAddr = mkOption {
          type = types.str;
        };

        serverPort = mkOption {
          type = types.port;
          default = 2277;
        };

        stateDir = mkOption {
          type = types.path;
          default = "/var/lib/frp";
        };

        proxies = mkOption {
          type = types.listOf tomlFormat.type;
          default = { };
        };
      };

      config = {
        services.frp.client.tls = {
          caFile = mkDefault "${cfg.stateDir}/tls/ca.crt";
          certFile = mkDefault "${cfg.stateDir}/tls/frpc.crt";
          keyFile = mkDefault "${cfg.stateDir}/tls/frpc.key";
        };

        services.frp.instances.frpc = {
          enable = true;
          role = "client";

          settings = {
            inherit (cfg) proxies;

            serverAddr = cfg.serverAddr;
            serverPort = cfg.serverPort;

            transport = {
              protocol = "quic";
              tls = {
                enable = true;
                trustedCaFile = cfg.tls.caFile;
                certFile = cfg.tls.certFile;
                keyFile = cfg.tls.keyFile;
              };
            };

            includes = [ "${includesDir}/*.toml" ];
          };
        };

        users.groups.frp = { };

        users.users.frp = {
          isSystemUser = true;
          group = "frp";
        };

        systemd.services.frp-frpc = {
          unitConfig.RequiresMountsFor = [ cfg.stateDir ];

          serviceConfig = {
            DynamicUser = mkForce false;
            User = "frp";
            Group = "frp";
            UMask = "0077";
          };
        };

        systemd.tmpfiles.rules = [
          "d ${cfg.stateDir} 0700 frp frp -"
          "d ${cfg.stateDir}/tls 0700 frp frp -"
          "d ${includesDir} 0700 frp frp -"
          "C ${includesDir}/proxies.toml 0600 frp frp - ${proxyTemplate}"
        ];

        persistence.directories = [
          {
            directory = cfg.stateDir;
            user = "frp";
            group = "frp";
            mode = "0700";
          }
        ];
      };
    };

  modules.services.frp.server.hjem =
    this@{ pkgs, ... }:
    let
      tomlFormat = pkgs.formats.toml { };

      cfg = this.config.services.frp.server;
      frpDir = "${this.config.directory}/.config/frp";

      configFile = tomlFormat.generate "frps.toml" {
        inherit (cfg) bindAddr bindPort;

        quicBindPort = cfg.bindPort;

        transport.tls = {
          trustedCaFile = cfg.tls.caFile;
          certFile = cfg.tls.certFile;
          keyFile = cfg.tls.keyFile;
          force = true;
        };
      };
    in
    {
      options.services.frp = {
        server = {
          tls = mkOption {
            type = types.submodule tlsModule;
          };

          bindAddr = mkOption {
            type = types.str;
            default = "0.0.0.0";
          };

          bindPort = mkOption {
            type = types.port;
            default = 2277;
          };
        };
      };

      config = {
        services.frp.server.tls = {
          caFile = mkDefault "${frpDir}/tls/ca.crt";
          certFile = mkDefault "${frpDir}/tls/frps.crt";
          keyFile = mkDefault "${frpDir}/tls/frps.key";
        };

        systemd.services.frps = {
          wantedBy = [ "default.target" ];
          after = [
            "network.target"
            "syslog.target"
          ];
          wants = [ "network.target" ];

          restartIfChanged = true;

          serviceConfig = {
            Type = "simple";

            ExecStartPre = [
              (pkgs.writeShellScript "frps-setup-dirs" ''
                set -eu
                ${pkgs.coreutils}/bin/install -d -m 0700 ${escapeShellArg frpDir} ${escapeShellArg "${frpDir}/tls"}
              '')
            ];

            ExecStart = "${pkgs.frp}/bin/frps --strict_config -c ${configFile}";

            Restart = "on-failure";
            RestartSec = 2;

            # hardening
            LockPersonality = true;
            MemoryDenyWriteExecute = true;
            NoNewPrivileges = true;
            PrivateTmp = true;
            PrivateDevices = true;
            ProtectSystem = "full";
            ProtectKernelTunables = true;
            ProtectKernelModules = true;
            ProtectControlGroups = true;
            ProtectClock = true;
            ProtectHostname = true;
            RestrictSUIDSGID = true;
            RestrictRealtime = true;
            SystemCallArchitectures = "native";
            UMask = "0077";
            RestrictAddressFamilies = [
              "AF_INET"
              "AF_INET6"
            ];
          };
        };
      };
    };
}
