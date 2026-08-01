{ config, lib, ... }:
{
  topLevel.nixosConfigurations.shipwreck = lib.nixosSystem {
    modules = [ config.modules.shipwreck.nixos ];
  };

  inputs.nixos-hardware = {
    url = "github:nixos/nixos-hardware";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  modules.shipwreck.nixos = {
    imports = with config.classes.nixos; [
      common
      desktop
      jorn
    ];

    boot.initrd.availableKernelModules = [
      "xhci_pci"
      "nvme"
      "usb_storage"
      "sd_mod"
      "rtsx_pci_sdmmc"
    ];

    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [ ];

    boot.initrd.kernelModules = [ ];
    boot.initrd.systemd.enable = true;

    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.systemd-boot.enable = true;

    # filesystem
    fileSystems."/boot" = {
      device = "/dev/disk/by-label/NIXBOOT";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };

    fileSystems."/" = {
      device = "/dev/disk/by-label/NIXROOT";
      fsType = "btrfs";
      options = [ "noatime" ];
    };

    # cpu
    hardware.cpu.intel.updateMicrocode = true;
    hardware.enableRedistributableFirmware = true;

    # networking
    networking.hostName = "shipwreck";

    networking.networkmanager = {
      enable = true;
      wifi.backend = "iwd";
    };

    services.openssh = {
      enable = true;
      ports = [ 2020 ];
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
      };
    };

    # misc
    services.greetd.settings.default_session.user = "jorn";

    # nix
    nixpkgs.config.allowUnfree = true;
    nixpkgs.localSystem.system = "x86_64-linux";
    system.stateVersion = "26.11";
  };
}
