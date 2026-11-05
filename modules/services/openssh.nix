{
  modules.services.openssh.nixos = _: {
    services.openssh = {
      enable = true;

      openFirewall = false;
      ports = [ 2288 ];

      hostKeys = [
        {
          type = "ed25519";
          path = "/etc/ssh/host_ed25519";
        }
      ];

      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        MaxAuthTries = 3;
        PerSourcePenalties = "crash:3600s authfail:3600s max:86400s";
      };
    };

    persistence.files = [
      {
        file = "/etc/ssh/host_ed25519";
        how = "symlink";
        configureParent = true;
      }
      {
        file = "/etc/ssh/host_ed25519.pub";
        how = "symlink";
        configureParent = true;
      }
    ];

    networking.firewall.extraCommands = ''
      iptables -I nixos-fw 1 -p tcp -s 192.168.1.0/24 --dport 2288 -j nixos-fw-accept
    '';
  };
}
