{
  modules.bluetooth.nixos = {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General.Experimental = true;
        General.FastConnectable = true;
        Policy.AutoEnable = true;
      };
    };

    persistence.directories = [
      "/var/lib/bluetooth"
    ];
  };
}
