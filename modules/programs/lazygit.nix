{ config, ... }:
{
  modules.programs.lazygit.hjem = { pkgs, ... }: {
    packages = [ pkgs.lazygit ];

    persistence.files = [
      ".local/state/lazygit/state.yml"
    ];
  };

  modules.programs.terminal.hjem = _: {
    imports = [ config.modules.programs.lazygit.hjem ];
  };
}
