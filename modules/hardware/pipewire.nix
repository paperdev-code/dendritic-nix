{
  modules.pipewire.nixos = {
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      pulse.enable = true;
      jack.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;

      wireplumber.enable = true;
    };
  };
}
