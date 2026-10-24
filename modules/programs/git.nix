{ config, paths, ... }:
{
  modules.git.hjem = { pkgs, ... }: {
    packages = [ pkgs.git ];

    files.".gitconfig".source = paths.dotfile ".gitconfig";
  };

  modules.terminal.hjem = {
    imports = [ config.modules.git.hjem ];
  };
}
