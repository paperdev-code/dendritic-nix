{ config, ... }:
{
  modules.common.nixos = _: {
    imports = with config.classes.nixos; [
      stubs
      nix
    ];

    hjem.extraModules = [
      config.modules.common.hjem
    ];
  };
}
