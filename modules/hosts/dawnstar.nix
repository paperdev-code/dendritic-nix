{
  config,
  lib,
  ...
}:
{
  topLevel.nixosConfigurations.dawnstar = lib.nixosSystem {
    modules = [ config.modules.dawnstar.nixos ];
  };

  modules.dawnstar.nixos = {
    imports = with config.classes.nixos; [
      common
      desktop
      devving
      disko
      gaming
      jorn
      nvidia
      persistence
    ];

    # boot
    boot.initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "ahci"
      "usb_storage"
      "usbhid"
      "sd_mod"
    ];

    boot.kernelModules = [ "kvm-amd" ];
    boot.extraModulePackages = [ ];

    boot.initrd.kernelModules = [ ];
    boot.initrd.systemd.enable = true;

    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.systemd-boot.enable = true;

    # filesystem
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

    # gpu
    hardware.nvidia = {
      prime = {
        sync.enable = true;
        amdgpuBusId = "PCI:17@0:0:0";
        nvidiaBusId = "PCI:1@0:0:0";
      };
    };

    # cpu
    hardware.enableRedistributableFirmware = true;
    hardware.cpu.amd.updateMicrocode = true;

    # networking
    networking.hostName = "dawnstar";

    # misc
    services.greetd.settings.default_session.user = "jorn";

    # nix
    nixpkgs.config.allowUnfree = true;
    nixpkgs.localSystem.system = "x86_64-linux";
    system.stateVersion = "26.11";
  };
}
