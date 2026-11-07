{
  config,
  inputs,
  lib,
  ...
}:
{
  readme = lib.mkOrder (config.chapters.hosts + 2) ''
    ### Stendarr

    `nix run github:nix-community/nixos-anywhere -- --flake .#stendarr build --target-host root@<ip address>`

    A NixOS powered _Acer Nitro Blaze 7_ to run a GregTech NH server.

    Features:

    - Also ephemeral using nix preservation and tmpfs.
    - OpenSSH server for remote configuration.
    - A TTY dashboard using Zellij.

    (silly image)
  '';

  topLevel.nixosConfigurations.stendarr = lib.nixosSystem {
    modules = [ config.modules.hosts.stendarr.nixos ];
  };

  modules.hosts.stendarr.nixos = _: {
    imports = with config.classes.nixos; [
      inputs.disko.nixosModules.disko
      boot
      common
      cpu.amd
      hardware.blazeSeven
      persistence
      performance
      services.dashboard
      services.openssh
      stubs
      users.default.jorn
      zswap
    ];

    boot.initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "thunderbolt"
      "usbhid"
      "usb_storage"
      "sd_mod"
      "sdhci_pci"
    ];

    boot.kernelParams = [
      "video=eDP-1:1920x1080@60"
    ];

    powerManagement = {
      cpuFreqGovernor = "powersave";
      cpufreq.min = 419175;
    };

    networking.hostName = "stendarr";

    services.dashboard.hardware = {
      keyboard = {
        path = "/dev/input/by-path/platform-i8042-serio-0-event-kbd";
        id = "platform-i8042-serio-0";
      };

      gamepad = {
        path = "/dev/input/by-id/usb-SU_Technology_Co._Ltd_Game_Controller_7582668A-event-joystick";
        id = "pci-0000:c4:00.3-usb-0:2:1.0";
      };
    };

    disko.devices = {
      disk.main = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-WD_PC_SN740_SDDPNQD-1T00_24371K804931";

        content.type = "gpt";
        content.partitions.NIXBOOT = {
          priority = 1;
          start = "1M";
          end = "2G";
          type = "EF00";

          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };

        content.partitions.NIXROOT = {
          size = "100%";
          content = {
            type = "btrfs";
            extraArgs = [ "-f" ];

            subvolumes = {
              "@persist" = {
                mountpoint = "/persist";
                mountOptions = [
                  "compress=zstd:3"
                  "discard=async"
                ];
              };

              "@persist.home" = {
                mountpoint = "/persist/home";
                mountOptions = [
                  "compress=zstd:3"
                  "discard=async"
                ];
              };

              "@nix" = {
                mountpoint = "/nix";
                mountOptions = [
                  "compress=zstd:3"
                  "discard=async"
                  "noatime"
                ];
              };
            };
          };
        };
      };

      nodev."/" = {
        fsType = "tmpfs";
        mountOptions = [
          "mode=0755"
          "size=2G"
          "noatime"
        ];
      };
    };

    swapDevices = [
      {
        device = "/persist/swapfile";
        size = 1024 * 16;
      }
    ];

    fileSystems."/persist".neededForBoot = true;
    persistence.persistentPath = "/persist";

    nixpkgs.config.allowUnfree = true;
    nixpkgs.hostPlatform = "x86_64-linux";
    system.stateVersion = "26.11";
  };
}
