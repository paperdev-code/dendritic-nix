{ inputs, ... }:
{
  inputs.hjem = {
    url = "github:feel-co/hjem";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  modules.hjem.nixos = {
    imports = [ inputs.hjem.nixosModules.default ];
  };
}
