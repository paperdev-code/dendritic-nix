{ inputs, ... }:
{
  modules.services.gregtech-nh.nixos =
    this@{ pkgs, ... }:
    let
      gregtech-nh-server =
        inputs.self.unfreePackages.${pkgs.stdenv.hostPlatform.system}.gregtech-nh-server;
    in
    {
      imports = [ "${inputs.minecraft}/modules/minecraft-servers.nix" ];

      services.minecraft-servers = {
        enable = true;
        eula = true;
        openFirewall = false;

        servers.gregtech-nh = {
          enable = true;
          package = gregtech-nh-server;
          restart = "on-failure";

          serverProperties = {
            server-port = 10265;
            server-address = "localhost";

            enable-rcon = false;
            enable-query = false;

            gamemode = 0;
            difficulty = 2;
            allow-flight = true;
            level-type = "rwg";
            view-distance = 24;
            spawn-protection = 0;

            max-players = 6;
            white-list = true;
            online-mode = true;
          };

          jvmOpts = [
            "-Xms8G"
            "-Xmx8G"
          ];

          symlinks.mods = "${gregtech-nh-server}/lib/mods";
          files.config = "${gregtech-nh-server}/lib/config";
        };
      };

      systemd.services."minecraft-server-gregtech-nh" = {
        serviceConfig = {
          TimeoutStartSec = 10;
          # additional hardening
          IPAddressDeny = "any"; # FIXME: breaks microsoft auth
          IPAddressAllow = [ "localhost" ];
        };
      };

      services.frp.client.proxies = [
        {
          name = "gregtech-nh-server";
          type = "tcp";
          localIP = "127.0.0.1";
          localPort = 10265;
          remotePort = 10265;
        }
      ];

      persistence.directories = [
        this.config.services.minecraft-servers.dataDir
      ];
    };
}
