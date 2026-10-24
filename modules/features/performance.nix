{ config, ... }:
{
  modules.performance.nixos = {
    imports = with config.classes.nixos; [
      scheduler
      xanmod
    ];
  };
}
