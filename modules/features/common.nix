{ config, ... }:
{
  modules.common.nixos = _: {
    imports = with config.classes.nixos; [
      doas
      locale
      nix
      stubs
    ];

    hjem.extraModules = [
      config.modules.common.hjem
    ];
  };

  modules.common.hjem = _: {
    imports = with config.classes.hjem.programs; [
      git
      helix
      lazygit
      proton-suite
    ];
  };
}
