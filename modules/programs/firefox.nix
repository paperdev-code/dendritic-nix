{ config, ... }:
{
  modules.programs.firefox.hjem = { pkgs, ... }: {
    packages = [ pkgs.firefox ];

    persistence.directories = [
      ".cache/mozilla/firefox"
      ".config/mozilla/firefox"
      ".mozilla"
    ];
  };

  modules.programs.graphical.hjem = _: {
    imports = [ config.modules.firefox.hjem ];
  };
}
