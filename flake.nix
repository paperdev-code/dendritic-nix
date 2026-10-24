{
  inputs.disko.url = "github:nix-community/disko?ref=master";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";
  inputs.hjem.url = "github:feel-co/hjem";
  inputs.hjem.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nix.url = "github:NixOS/nix?ref=master";
  inputs.nix.flake = false;
  inputs.nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
  inputs.preservation.url = ./vendor/preservation/module.nix;
  inputs.preservation.flake = false;
  inputs.systems.url = ./systems.nix;
  inputs.systems.flake = false;

  outputs =
    inputs@{ nixpkgs, ... }:
    (import ./lib/dendritic.nix { inherit (nixpkgs) lib; }).mkFlake ./modules inputs;
}
