{
  modules.programs.vesktop.hjem = { pkgs, ... }: {
    packages = with pkgs; [
      vesktop
    ];

    persistence.directories = [
      ".config/vesktop"
    ];
  };
}
