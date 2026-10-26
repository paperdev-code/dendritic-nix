{
  modules.programs.lazygit.hjem = { pkgs, ... }: {
    packages = [ pkgs.lazygit ];

    persistence.files = [
      ".local/state/lazygit/state.yml"
    ];
  };
}
