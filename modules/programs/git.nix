{ paths, ... }:
{
  modules.programs.git.hjem = { pkgs, ... }: {
    packages = [ pkgs.git ];
    files.".gitconfig".source = paths.dotfile ".gitconfig";
  };
}
