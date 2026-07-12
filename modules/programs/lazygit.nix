{
  modules.lazygit.hjem = this: {
    packages = with this.pkgs; [
      lazygit
    ];

    persistence.directories = [
      ".local/state/lazygit/state.yml"
    ];
  };
}
