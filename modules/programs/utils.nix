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
}
