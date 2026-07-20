{ config, paths, ... }:
{
  modules.niri.nixos = { pkgs, ... }: {
    imports = with config.classes.nixos; [
      audio
      networking
    ];

    environment.systemPackages = with pkgs; [
      brightnessctl
      libnotify
      niri
      phinger-cursors
      playerctl
      xwayland-satellite
    ];

    programs.uwsm = {
      enable = true;
      waylandCompositors.niri = {
        prettyName = "Niri";
        comment = "A scrolling window manager";
        binPath = "/run/current-system/sw/bin/niri-session";
      };
    };

    services.graphical-desktop.enable = true;
    services.displayManager.sessionPackages = [
      pkgs.niri
    ];

    security.polkit.enable = true;

    programs.xwayland.enable = true;

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
        xdg-desktop-portal-gnome
      ];
      config.niri = {
        default = [
          "gnome"
          "gtk"
        ];
        "org.freedesktop.impl.portal.Access" = "gtk";
        "org.freedesktop.impl.portal.Notification" = "gtk";
        "ork.freedesktop.impl.portal.Secret" = "None";
      };
    };

    hjem.extraModules = [
      config.modules.niri.hjem
    ];
  };

  modules.niri.hjem = {
    imports = with config.classes.hjem; [
      ghostty
    ];

    files.".config/niri/binds.kdl".source = paths.dotfile "niri/binds.kdl";
    files.".config/niri/config.kdl".source = paths.dotfile "niri/config.kdl";
    files.".config/niri/outputs.kdl".source = paths.dotfile "niri/outputs.kdl";
  };
}
