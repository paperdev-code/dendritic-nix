{ config, ... }:
{
  modules.keyring.nixos = {
    services.gnome.gnome-keyring.enable = true;

    hjem.extraModules = [
      config.modules.keyring.hjem
    ];
  };

  modules.keyring.hjem = {
    persistence.directories = [
      ".local/share/keyrings"
    ];

    environment.sessionVariables = {
      SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/gcr/ssh";
    };
  };
}
