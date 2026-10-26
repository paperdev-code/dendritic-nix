{ config, ... }:
{
  modules.users.jorn.nixos = _: {
    users.users.jorn = {
      description = "Jorn Veken";
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "plugdev"
      ];
    };

    services.openssh.settings.allowUsers = [ "jorn" ];

    hjem.users.jorn = { };
  };

  modules.users.default.jorn.nixos = _: {
    imports = [ config.modules.users.jorn.nixos ];

    services.displayManager.autoLogin.user = "jorn";
    services.greetd.settings.default_session.user = "jorn";
  };
}
