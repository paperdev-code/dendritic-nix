{ config, ... }:
{
  modules.desktop.nixos = _: {
    imports = with config.classes.nixos; [
      keyring
      programs.noctalia
      programs.noctalia-greeter
      programs.umbriel
    ];

    hjem.extraModules = [ config.modules.desktop.hjem ];
  };

  modules.desktop.hjem = _: {
    imports = with config.classes.hjem.programs; [
      firefox
      ghostty
    ];
  };
}
