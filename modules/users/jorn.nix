{ config, paths, ... }:
{
  modules.users.jorn.nixos = this: {
    users.users.jorn = {
      description = "Jorn Veken";
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "plugdev"
      ];

      openssh.authorizedKeys.keyFiles = [
        (paths.keys "jorn@${this.config.networking.hostName}.pub")
      ];
    };

    services.openssh.settings.AllowUsers = [ "jorn" ];

    hjem.users.jorn = { };
  };

  modules.users.default.jorn.nixos = _: {
    imports = [ config.modules.users.jorn.nixos ];

    services.displayManager.autoLogin.user = "jorn";
    services.greetd.settings.default_session.user = "jorn";
  };
}
