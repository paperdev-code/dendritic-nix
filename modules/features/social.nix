{ config, ... }:
{
  modules.social.nixos = _: {
    hjem.extraModules = [ config.modules.social.hjem ];
  };

  modules.social.hjem = _: {
    imports = with config.classes.hjem.programs; [
      vesktop
      signal
    ];
  };
}
