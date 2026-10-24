{ paths, ... }:
{
  modules.ghostty.hjem = { pkgs, ... }: {
    packages = [ pkgs.ghostty ];

    persistence.directories = [
      ".config/ghostty"
      ".local/share/ghostty"
    ];

    files.".config/ghostty/config.ghostty".source = paths.dotfile "ghostty/config.ghostty";
  };
}
