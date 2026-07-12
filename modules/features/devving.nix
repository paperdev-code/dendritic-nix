{ config, inputs, ... }:
{
  modules.devving.nixos = { pkgs, ... }: {
    programs.direnv.enable = true;
    programs.nix-ld.enable = true;
    programs.ssh.startAgent = true;

    hjem.extraModules = [ config.modules.devving.hjem ];

    fonts.packages = [
      inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.berkeley-mono
    ];
  };

  modules.devving.hjem = {
    imports = with config.classes.hjem; [
      git
      helix
      lazygit
    ];

    persistence.directories = [
      {
        directory = ".ssh";
        mode = "0700";
      }
    ];
  };
}
