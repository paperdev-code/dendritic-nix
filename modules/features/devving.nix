{ config, inputs, ... }:
{
  modules.devving.nixos = { pkgs, ... }: {
    programs.direnv.enable = true;
    programs.nix-ld.enable = true;

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
      llm
    ];

    persistence.directories = [
      ".local/share/direnv"
      {
        directory = ".ssh";
        mode = "0700";
      }
    ];
  };
}
