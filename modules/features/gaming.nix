{ config, ... }:
{
  modules.gaming.nixos = _: {
    imports = with config.classes.nixos.programs; [
      steam
    ];

    hjem.extraModules = [
      config.modules.gaming.hjem
    ];
  };

  modules.gaming.hjem = _: {
    imports = with config.classes.hjem.programs; [
      minecraft
    ];
  };
}
