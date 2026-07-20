{
  config,
  inputs,
  paths,
  ...
}:
{
  modules.noctalia.nixos = { pkgs, ... }: {
    imports = [
      inputs.noctalia.nixosModules.default
      inputs.noctalia-greeter.nixosModules.default
    ];

    environment.systemPackages = [
      pkgs.pywalfox-native
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
