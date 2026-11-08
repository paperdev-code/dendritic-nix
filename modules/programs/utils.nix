{
  modules.programs.utils.nixos = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      asciinema
      btop
      coreutils
      curl
      fastfetch
      ripgrep
      tree
    ];
  };

  modules.programs.utils.hjem = { pkgs, ... }: {
    packages = with pkgs; [
      asciinema
      btop
      fastfetch
      ripgrep
      tree
    ];
  };
}
