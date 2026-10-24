{ config, paths, ... }:
{
  modules.programs.git.hjem = { pkgs, ... }: {
    packages = [ pkgs.git ];

    files.".gitconfig".source = paths.dotfile ".gitconfig";
  };

  modules.programs.terminal.hjem = _: {
    imports = [ config.modules.git.hjem ];
  };
}
