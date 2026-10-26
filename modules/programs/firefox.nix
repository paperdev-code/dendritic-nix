{
  modules.programs.firefox.hjem = { pkgs, ... }: {
    packages = [ pkgs.firefox ];

    persistence.directories = [
      ".cache/mozilla/firefox"
      ".config/mozilla/firefox"
      ".mozilla"
    ];
  };
}
