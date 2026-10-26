{ config, ... }:
{
  modules.audio.nixos = _: {
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      pulse.enable = true;
      jack.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;

      wireplumber.enable = true;
    };

    hjem.extraModules = [ config.modules.audio.hjem ];
  };

  modules.audio.hjem = _: {
    persistence.directories = [
      ".config/pipewire"
      ".config/wireplumber"
    ];
  };
}
