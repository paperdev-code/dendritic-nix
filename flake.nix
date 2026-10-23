{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
  inputs.systems.url = "github:nix-systems/default";

  outputs =
    inputs@{ nixpkgs, ... }:
    (import ./lib/dendritic.nix { inherit (nixpkgs) lib; }).mkFlake ./modules inputs;
}
