{ config, paths, ... }:
{
  modules.helix.hjem = { pkgs, ... }: {
    packages = with pkgs; [
      helix
      nixd
    ];

    environment.sessionVariables = {
      EDITOR = "hx";
      VISUAL = "hx";
    };

    files.".config/helix/config.toml".source = paths.dotfile "helix/config.toml";
  };

  modules.terminal.hjem = {
    imports = [ config.modules.helix.hjem ];
  };
}
