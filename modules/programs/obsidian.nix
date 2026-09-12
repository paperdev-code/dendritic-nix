{
  modules.obsidian.hjem = { pkgs, ... }: {
    packages = [ pkgs.obsidian ];

    persistence.directories = [
      ".config/obsidian"
      "Obsidian Vault"
    ];
  };
}
