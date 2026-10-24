{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
  inputs.systems.url = ./systems.nix;
  inputs.systems.flake = false;

  outputs =
    inputs@{ nixpkgs, ... }:
    (import ./lib/dendritic.nix { inherit (nixpkgs) lib; }).mkFlake ./modules inputs;
}
