{ config, ... }:
{
  modules.jorn.nixos = this: {
    users.users.jorn = {
      isNormalUser = true;
      description = "Jorn Veken";
      extraGroups = [
        "wheel"
        "plugdev"
      ];
    };

    services.displayManager.autoLogin.user = "jorn";

    hjem.users.jorn = config.modules.jorn.hjem;
  };

  modules.jorn.hjem = {
    imports = with config.classes.hjem; [
      common
      vesktop
    ];
  };
}
