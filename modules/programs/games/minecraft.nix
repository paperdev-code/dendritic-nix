{
  modules.minecraft.hjem = this: {
    packages = with this.pkgs; [
      prismlauncher
    ];

    persistence.directories = [
      ".local/share/PrismLauncher"
    ];
  };
}
