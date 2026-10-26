{ config, ... }:
{
  modules.keyring.nixos = _: {
    services.gnome.gnome-keyring.enable = true;

    hjem.extraModules = [
      config.modules.keyring.hjem
    ];
  };

  modules.keyring.hjem = _: {
    persistence.directories = [
      ".local/share/keyrings"
    ];
  };
}
