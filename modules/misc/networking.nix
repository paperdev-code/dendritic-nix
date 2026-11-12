{
  modules.networking.nixos = _: {
    networking = {
      networkmanager.enable = true;
      nftables.enable = true;
    };

    persistence.directories = [
      "/etc/NetworkManager/system-connections"
    ];
  };
}
