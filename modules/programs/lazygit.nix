{ config, ... }:
{
  modules.lazygit.hjem = { pkgs, ... }: {
    packages = [ pkgs.lazygit ];

    persistence.files = [
      ".local/state/lazygit/state.yml"
    ];
  };

  modules.terminal.hjem = {
    imports = [ config.modules.lazygit.hjem ];
  };
}
