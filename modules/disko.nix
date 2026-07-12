{ inputs, ... }:
{
  modules.disko.nixos = {
    imports = [
      inputs.disko.nixosModules.disko
    ];
  };
}
