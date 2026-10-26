{ paths, ... }:
{
  modules.programs.ghostty.hjem = { pkgs, ... }: {
    packages = [ pkgs.ghostty ];

    persistence.directories = [
      ".config/ghostty"
      ".local/share/ghostty"
    ];

    files.".config/ghostty/config.ghostty".source = paths.dotfile "ghostty/config.ghostty";
  };

  modules.programs.umbriel.hjem = _: {
    programs.umbriel.settings.keybinds."Mod+Enter" = "spawn:ghostty +new-window";
  };
}
