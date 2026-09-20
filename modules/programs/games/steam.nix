{ config, ... }:
{
  modules.steam.nixos = { pkgs, ... }: {
    hjem.extraModules = [ config.modules.steam.hjem ];
    programs.steam = {
      enable = true;
      extraCompatPackages = [
        pkgs.proton-ge-bin
      ];
    };
  };

  modules.steam.hjem = {
    persistence.directories = [
      ".steam"
      ".local/share/Steam"
    ];
  };
}
