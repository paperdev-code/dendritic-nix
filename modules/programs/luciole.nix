{
  config,
  inputs,
  paths,
  ...
}:
{
  modules.programs.luciole.nixos = _: {
    imports = [ inputs.luciole.nixosModules.default ];

    programs.luciole.enable = true;

    hjem.extraModules = [
      config.modules.programs.luciole.hjem
    ];
  };

  modules.programs.luciole.hjem = _: {
    files.".config/luciole/config.toml" = {
      source = paths.dotfile "luciole/config.toml";
      type = "copy";
    };

    persistence.directories = [
      ".local/state/luciole"
      ".cache/thumbnails"
    ];

    persistence.files = [
      ".config/gtk-3.0/bookmarks"
    ];
  };
}
