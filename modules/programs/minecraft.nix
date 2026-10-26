{
  modules.programs.minecraft.hjem = { pkgs, ... }: {
    packages = with pkgs; [
      prismlauncher
    ];

    persistence.directories = [
      ".local/share/PrismLauncher"
    ];
  };
}
