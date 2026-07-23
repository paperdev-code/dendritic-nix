{ inputs, ... }:
{
  inputs.disko = {
    url = "github:nix-community/disko";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  modules.disko.nixos = {
    imports = [
      inputs.disko.nixosModules.disko
    ];
  };
}
