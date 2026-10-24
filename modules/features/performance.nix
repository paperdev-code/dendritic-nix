{ config, ... }:
{
  modules.performance.nixos = _: {
    imports = with config.classes.nixos; [
      scheduler
      xanmod
    ];
  };
}
