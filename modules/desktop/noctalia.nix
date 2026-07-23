{
  config,
  inputs,
  paths,
  ...
}:
{
  inputs = {
    noctalia.url = "github:noctalia-dev/noctalia";
    noctalia.inputs.nixpkgs.follows = "nixpkgs";
    noctalia-greeter.url = "github:noctalia-dev/noctalia-greeter";
    noctalia-greeter.inputs.nixpkgs.follows = "nixpkgs";
  };

  modules.noctalia.nixos = {
    imports = [
      inputs.noctalia.nixosModules.default
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

    persistence.directories = [
      ".local/state/noctalia"
    ];
  };
}
