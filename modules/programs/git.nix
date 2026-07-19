{ paths, ... }:
{
  modules.git.hjem = this: {
    packages = with this.pkgs; [
      git
    ];

    files.".gitconfig".source = paths.dotfile ".gitconfig";
  };
}
