{ inputs, ... }:
{
  modules.programs.noctalia-greeter.nixos = _: {
    imports = [
      inputs.noctalia-greeter.nixosModules.default
    ];

    services.displayManager.noctalia-greeter.enable = true;
    programs.dconf.enable = true;

    persistence.files = [
      "/var/lib/noctalia-greeter/appearance.json"
    ];
  };
}
