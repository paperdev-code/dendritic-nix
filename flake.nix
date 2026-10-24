{
  inputs.nix.url = "github:NixOS/nix?ref=master";
  inputs.nix.flake = false;
  inputs.nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
  inputs.preservation.url = "github:nix-community/preservation";
  inputs.systems.url = ./systems.nix;
  inputs.systems.flake = false;

  outputs =
    inputs@{ nixpkgs, ... }:
    (import ./lib/dendritic.nix { inherit (nixpkgs) lib; }).mkFlake ./modules inputs;
}
