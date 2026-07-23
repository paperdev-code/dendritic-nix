{ inputs, ... }:
{
  modules.hjem.nixos = {
    imports = [ inputs.hjem.nixosModules.default ];
  };
}
