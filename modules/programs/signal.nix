{
  modules.signal.hjem = { pkgs, ... }: {
    packages = [
      pkgs.signal-desktop
    ];

    persistence.directories = [
      ".config/Signal"
    ];
  };
}
