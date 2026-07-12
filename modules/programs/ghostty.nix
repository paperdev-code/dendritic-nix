{ paths, ... }:
{
  modules.ghostty.hjem = this: {
    packages = with this.pkgs; [
      ghostty
    ];

    persistence.directories = [
      ".config/ghostty"
      ".local/share/ghostty"
    ];

    files.".config/ghostty/config.ghostty".source = paths.dotfile "ghostty/config.ghostty";
  };
}
