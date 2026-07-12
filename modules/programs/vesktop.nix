{
  modules.vesktop.hjem = this: {
    packages = with this.pkgs; [
      vesktop
    ];

    persistence.directories = [
      ".config/vesktop"
    ];
  };
}
