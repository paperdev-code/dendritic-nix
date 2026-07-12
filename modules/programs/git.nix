{
  modules.git.hjem = this: {
    packages = with this.pkgs; [
      git
    ];

    persistence.directories = [
      ".gitconfig"
    ];
  };
}
