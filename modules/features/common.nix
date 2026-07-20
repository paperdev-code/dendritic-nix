{ config, ... }:
{
  modules.common.nixos = { pkgs, ... }: {
    imports = with config.classes.nixos; [
      bluetooth
      doas
      hjem
      locale
      mntdir
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

    services.fwupd.enable = true;
  };

  modules.common.hjem = {
    persistence.directories = [
      {
        directory = ".ssh";
        mode = "0700";
      }
    ];
  };
}
