{ config, ... }:
{
  modules.steam.nixos = {
    hjem.extraModules = [ config.modules.steam.hjem ];
    programs.steam.enable = true;
  };

  modules.steam.hjem = {
    persistence.directories = [
      ".steam"
      ".local/share/Steam"
    ];
  };
}
