{
  modules.nvidia.nixos = this: {
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.graphics.enable = true;

    hardware.nvidia = {
      modesetting.enable = true;
      nvidiaSettings = true;
      open = true;
      package = this.config.boot.kernelPackages.nvidiaPackages.production;
    };
  };
}
