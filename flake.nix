{
  inputs.disko.url = "github:nix-community/disko?ref=master";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";
  inputs.hjem.url = "github:feel-co/hjem";
  inputs.hjem.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nix.url = "github:NixOS/nix?ref=master";
  inputs.nix.flake = false;
  inputs.nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
  inputs.noctalia.url = "github:noctalia-dev/noctalia?ref=v5.4.0";
  inputs.noctalia.inputs.nixpkgs.follows = "nixpkgs";
  inputs.noctalia-greeter.url = "github:noctalia-dev/noctalia-greeter?ref=v1.7.0";
  inputs.noctalia-greeter.inputs.nixpkgs.follows = "nixpkgs";
  inputs.preservation.url = ./vendor/preservation/module.nix;
  inputs.preservation.flake = false;
  inputs.systems.url = ./systems.nix;
  inputs.systems.flake = false;
  inputs.umbriel.url = "github:noctalia-dev/umbriel?ref=main";
  inputs.umbriel.inputs.nixpkgs.follows = "nixpkgs";

  outputs =
    inputs@{ nixpkgs, ... }:
    (import ./lib/dendritic.nix { inherit (nixpkgs) lib; }).mkFlake ./modules inputs;
}
