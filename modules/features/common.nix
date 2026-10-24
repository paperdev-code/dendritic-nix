{ config, ... }:
{
  modules.common.nixos = {
    imports = with config.classes.nixos; [
      stubs
      nix
    ];

    hjem.extraModules = [
      config.modules.common.hjem
    ];
  };
}
