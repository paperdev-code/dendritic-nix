{ config, ... }:
{
  topLevel.nixosModules = config.classes.nixos;
}
