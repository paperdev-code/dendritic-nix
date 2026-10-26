{
  config,
  inputs,
  lib,
  ...
}:
{
  topLevel.nixosConfigurations.dawnstar = lib.nixosSystem {
    modules = [ config.modules.hosts.dawnstar.nixos ];
  };

  modules.hosts.dawnstar.nixos = _: {
    imports = with config.classes.nixos; [
      inputs.disko.nixosModules.disko
      boot
      cpu.amd
      desktop
      hjem
      gaming
      gpu.nvidia
      persistence
      performance
      social
      users.default.jorn
    ];

    boot.initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "ahci"
      "usb_storage"
      "usbhid"
      "sd_mod"
    ];

    networking.hostName = "dawnstar";

    disko.devices = {
      disk.main = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-WD_BLACK_SN850X_2000GB_245039807100";

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
          "size=4G"
          "noatime"
        ];
      };
    };

    fileSystems."/persist".neededForBoot = true;
    persistence.persistentPath = "/persist";

    nixpkgs.config.allowUnfree = true;
    nixpkgs.hostPlatform = "x86_64-linux";
    system.stateVersion = "26.11";
  };
}
