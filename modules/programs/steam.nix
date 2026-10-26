{ config, ... }:
{
  modules.programs.steam.nixos = { pkgs, ... }: {
    programs.steam = {
      enable = true;
      extraCompatPackages = [
        pkgs.proton-ge-bin
      ];
      remotePlay.openFirewall = true;
    };

    hjem.extraModules = [ config.modules.programs.steam.hjem ];
  };

  modules.programs.steam.hjem = _: {
    persistence.directories = [
      ".steam"
      ".local/share/Steam"
    ];
  };
}
