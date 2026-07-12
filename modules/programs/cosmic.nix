{ config, lib, ... }:
let
  inherit (lib) mkForce;
in
{
  modules.cosmic.nixos = { pkgs, ... }: {
    hjem.extraModules = [
      config.modules.cosmic.hjem
    ];

    services.displayManager.cosmic-greeter.enable = true;
    services.displayManager.autoLogin.enable = true;
    services.desktopManager.cosmic.enable = true;

    environment.cosmic.excludePackages = with pkgs; [
      cosmic-store
      cosmic-edit
    ];

    services.geoclue2.enable = mkForce false;
    services.gnome.gnome-keyring.enable = mkForce false;
    services.gvfs.enable = mkForce false;
    services.avahi.enable = mkForce false;
  };

  modules.cosmic.hjem = {
    persistence = {
      files = [
        ".config/cosmic-initial-setup-done"
        ".local/state/cosmic-comp/outputs.ron"
      ];
      directories = [
        ".config/cosmic"
      ];
    };
  };
}
