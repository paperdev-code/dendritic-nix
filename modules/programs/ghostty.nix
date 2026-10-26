{ paths, inputs, ... }:
{
  modules.programs.ghostty.hjem = { pkgs, ... }: {
    packages = [
      pkgs.ghostty
      inputs.self.unfreePackages.${pkgs.stdenv.hostPlatform.system}.berkeley-mono
    ];

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
