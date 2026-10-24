{ config, paths, ... }:
{
  modules.programs.helix.hjem = { pkgs, ... }: {
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

  modules.programs.terminal.hjem = _: {
    imports = [ config.modules.programs.helix.hjem ];
  };
}
