{
  modules.cpu = {
    amd.nixos = _: {
      boot.kernelModules = [ "kvm-amd" ];
      hardware.enableRedistributableFirmware = true;
      hardware.cpu.amd.updateMicrocode = true;
    };
  };
}
