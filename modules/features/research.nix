{ config, ... }:
{
  modules.research.nixos = {
    hjem.extraModules = [ config.modules.research.hjem ];
  };

  modules.research.hjem = {
    imports = with config.classes.hjem; [
      obsidian
    ];
  };
}
