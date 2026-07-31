{
  config,
  inputs,
  paths,
  ...
}:
{
  inputs.noctalia-greeter = {
    url = "github:noctalia-dev/noctalia-greeter";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  modules.noctalia.nixos = {
    imports = [
      inputs.noctalia-greeter.nixosModules.default
    ];

    programs.noctalia = {
      enable = true;
      recommendedServices.enable = true;
    };

    programs.noctalia-greeter.enable = true;
    programs.dconf.enable = true;

    persistence.files = [
      "/var/lib/noctalia-greeter/appearance.json"
    ];

    hjem.extraModules = [
      config.modules.noctalia.hjem
    ];
  };

  modules.noctalia.hjem = {
    files.".config/niri/noctalia.kdl".source = paths.dotfile "niri/noctalia.kdl";
    files.".config/noctalia/wallpaper.toml".source = paths.dotfile "noctalia/wallpaper.toml";
    files.".config/noctalia/assets/wallpaper.jpg".source =
      paths.dotfile "noctalia/assets/wallpaper.jpg";

    persistence.directories = [
      ".local/state/noctalia"
    ];
  };
}
