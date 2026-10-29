{
  modules.bluetooth.nixos = { pkgs, ... }: {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General.Experimental = true;
        General.FastConnectable = true;
        Policy.AutoEnable = true;
      };
      package = pkgs.bluez-experimental;
    };

    persistence.directories = [
      "/var/lib/bluetooth"
    ];
  };
}
