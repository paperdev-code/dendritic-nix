{ config, ... }:
{
  modules.common.nixos = _: {
    imports = with config.classes.nixos; [
      nix
      stubs
    ];

    hjem.extraModules = [
      config.modules.common.hjem
    ];
  };

  modules.common.hjem = _: {
    imports = with config.classes.hjem.programs; [
      helix
      git
    ];
  };
}
