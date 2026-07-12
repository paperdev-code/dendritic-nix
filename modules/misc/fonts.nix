{ config, ... }:
{
  modules.fonts.nixos = {
    packages = [
      config.top-level.packages.berkeley-mono
    ];
  };
}
