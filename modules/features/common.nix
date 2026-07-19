{ config, ... }:
{
  modules.common.nixos = { pkgs, ... }: {
    imports = with config.classes.nixos; [
      bluetooth
      devving
      hjem
      locale
      mntdir
      pipewire
      stubs
    ];

    environment.systemPackages = with pkgs; [
      git
      tree
      wget
    ];

    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "pipe-operators"
      ];
      download-buffer-size = 524288000;
    };

    programs.vim = {
      enable = true;
      defaultEditor = true;
    };

    networking.networkmanager.enable = true;

    services.fwupd.enable = true;
    services.power-profiles-daemon.enable = true;
    services.upower.enable = true;
  };

  modules.common.hjem = {
    imports = with config.classes.hjem; [
      firefox
      ghostty
    ];

    persistence.directories = [
      {
        directory = ".ssh";
        mode = "0700";
      }
    ];
  };
}
