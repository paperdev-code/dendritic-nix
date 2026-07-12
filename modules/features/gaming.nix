{ config, ... }:
{
  modules.gaming.nixos = {
    imports = with config.classes.nixos; [
      steam
    ];

    hjem.extraModules = [ config.modules.gaming.hjem ];
  };

  modules.gaming.hjem = {
    imports = with config.classes.hjem; [
      minecraft
    ];
  };
}
