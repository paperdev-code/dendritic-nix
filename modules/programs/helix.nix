{ paths, ... }:
{
  modules.helix.hjem = this: {
    packages = with this.pkgs; [
      helix
      nixd
    ];

    environment.sessionVariables = {
      EDITOR = "hx";
      VISUAL = "hx";
    };

    files.".config/helix/config.toml".source = paths.dotfile "helix/config.toml";
  };
}
