{
  modules.zswap.nixos = this: {
    boot.zswap = {
      enable = true;
      maxPoolPercent = 35;
      shrinkerEnabled = true;
      compressor = "zstd";
      acceptThresholdPercent = 90;
    };

    assertions = [
      {
        assertion = this.config.swapDevices != [ ];
        message = "zswap won't work correctly without swap";
      }
    ];
  };
}
