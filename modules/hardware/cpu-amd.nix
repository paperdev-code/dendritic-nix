{
  modules.cpu-amd.nixos = {
    boot.kernelModules = [ "kvm-amd" ];

    hardware.enableRedistributableFirmware = true;
    hardware.cpu.amd.updateMicrocode = true;
  };
}
