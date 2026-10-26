{
  config,
  inputs,
  paths,
  ...
}:
{
  modules.programs.noctalia.nixos = _: {
    imports = [
      inputs.noctalia.nixosModules.default
    ];

    programs.noctalia = {
      enable = true;
      recommendedServices.enable = true;
    };

    hjem.extraModules = [
      config.modules.programs.noctalia.hjem
    ];
  };

  modules.programs.noctalia.hjem = _: {
    programs.umbriel.settings.include.files = [
      "noctalia.toml"
    ];

    files.".config/umbriel/noctalia.toml" = {
      source = paths.dotfile "umbriel/noctalia.toml";
      type = "copy";
    };
    files.".config/noctalia/wallpaper.jpg".source = paths.dotfile "noctalia/wallpaper.jpg";

    persistence.directories = [
      ".local/state/noctalia"
    ];
  };
}
