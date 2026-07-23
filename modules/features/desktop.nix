{ config, ... }:
{
  modules.desktop.nixos = {
    imports = with config.classes.nixos; [
      niri
      noctalia
    ];

    hjem.extraModules = [
      config.modules.desktop.hjem
    ];
  };

  modules.desktop.hjem = {
    imports = with config.classes.hjem; [
      firefox
      proton
    ];
  };
}
