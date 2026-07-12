{
  # TODO: add firefox addons back
  # 1. we need to generate the profiles.ini
  # 2. place xpi files into <profile>/extensions directory

  modules.firefox.hjem = this: {
    packages = with this.pkgs; [
      firefox
    ];

    persistence.directories = [
      ".config/mozilla/firefox"
      ".cache/mozilla/firefox"
    ];
  };
}
